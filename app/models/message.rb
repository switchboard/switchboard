class Message < ActiveRecord::Base
  include AASM

  belongs_to :from_phone_number, class_name: 'PhoneNumber'
  belongs_to :recipient, :class_name => 'Contact'
  belongs_to :list

  attr_accessible :from, :body

  aasm do
    state :incoming, initial: true
    state :processing
    state :in_send_queue
    state :needs_confirmation
    state :handled
    state :forwarded_to_admin
    state :sent
    state :failure
    state :ignored
    # Old outgoing/error messages have other states, not including them here.

    event :mark_processing do
      error do |e|
        update_column(:aasm_state, 'failure')
        Airbrake.notify(e)
      end

      transitions :from => :incoming, :to => :processing, guard: :ready_for_processing?
    end

    event :mark_handled do
      transitions from: :processing, to: :handled
    end

    event :mark_administered do
      transitions from: :processing, to: :forwarded_to_admin
    end

    event :mark_needs_confirmation do
      transitions from: :processing, to: :needs_confirmation
    end

    event :queue_to_send do
      before do
        self.queued_at = Time.now
      end
      transitions from: :processing, to: :in_send_queue
    end

    event :mark_confirmed do
      after do
        self.queue_to_send!
      end
      transitions from: :needs_confirmation, to: :processing
    end

    event :mark_sent do
      before do
        self.sent_at = Time.now
      end
      transitions from: :in_send_queue, to: :sent
    end

    event :mark_failure do
      transitions to: :failure
    end

    event :mark_ignored do
      transitions from: :processing, to: :ignored
    end
  end

  before_create :set_from_number, :set_list
  after_create :enqueue_incoming

  scope :recent, order('created_at DESC')

  def self.within_days(num_days)
    where('updated_at > ?', num_days.days.ago)
  end

  def self.for_display
    where(aasm_state: ['incoming', 'processing', 'needs_confirmation', 'in_send_queue', 'sent', 'forwarded_to_admin'])
  end

  def from_email_gateway?
    from =~ /@/
  end

  def from_web?
    false
  end

  def sender
    from_phone_number.try(:contact)
  end

  def sender_name_or_number
    if sender && sender.full_name.present?
      sender.full_name
    else
      from_phone_number.number
    end
  end

  def can_be_confirmed?
    needs_confirmation? && created_at > Settings.message_confirmation_time.minutes.ago
  end

  ## returns phone number of message sender
  # TODO EmailMessage should probably just set from appropriately
  def sender_number
    if self.is_a?(EmailMessage)
      number
    else
      from
    end
  end

  def tokens
    @tokens ||= body.split(' ')
  end

  def process
    begin
      first_token = tokens.first.downcase
      if tokens.length < 4 && locale = I18n.locale_for(key: 'list_commands.join', val: first_token)
        list.handle_join_message(self, locale)
        mark_handled!
      elsif tokens.length < 4 && locale = I18n.locale_for(key: 'list_commands.leave', val: first_token)
        list.handle_leave_message(self, locale)
        mark_handled!
      elsif tokens.length < 4 && locale = I18n.locale_for(key: 'list_commands.confirm', val: first_token)
        list.handle_confirmation_message(self, locale)
        mark_handled!
      elsif list.can_send_message?(self)
        list.handle_send_action(self)
        queue_to_send!
      elsif list.message_needs_confirmation?(self)
        list.send_confirmation_message(self)
        mark_needs_confirmation!
      elsif list.can_admin_message?(self)
        list.send_admin_message(self)
        mark_administered!
      else
        mark_ignored!
      end

    rescue => e
      logger = Resque.logger || Rails.logger
      logger.info "Exception while processing message #{id}"
      logger.info "Error: " + e.inspect
      logger.info "Backtrace: " + e.backtrace.inspect
      logger.info "e: " + e.to_s
      Airbrake.notify(e)

      mark_failure!
    end
  end

  def send_confirmed
    list.handle_send_action(self)
    queue_to_send!
  end

  def increment_outgoing_count
    $redis.incr("msg_out_#{id}").to_i
  end

  def self.increment_outgoing_count(message_id)
    $redis.incr("msg_out_#{message_id}").to_i
  end

  def outgoing_count
    ($redis.get("msg_out_#{id}") || 0).to_i
  end

  def percent_complete
    return 100 if sent?
    (outgoing_count.to_f / outgoing_total.to_f).round(0)
  end

  private

  # Would rather have this in an aasm state, but after_enter
  # on :incoming happens before the object has an id
  def enqueue_incoming
    Resque.enqueue(IncomingMessageJob, id)
  end

  # TODO would be nice to throw different errors based on what was missing
  def ready_for_processing?
    list.present? && body.present?
  end

  def set_from_number
    return unless sender_number
    incoming_number_str = sender_number.to_s.gsub('+1', '')

    if incoming_number_str.present?
      self.from_phone_number = PhoneNumber.find_or_create_by_number(incoming_number_str)

      # TODO: handle this more elegantly (in EmailMessage)
      # If the message comes via email, save the carrier address.
      if is_a?(EmailMessage)
        from_phone_number.update_column(:provider_email, carrier)
      end
    end
  end

  def set_list
    # Web messages already have list set
    return if list_id.present?

    incoming = IncomingPhoneNumber.find_by_phone_number(to)
    if incoming
      self.list = incoming.list
      ## Non-keyword list (assigned phone number)
      list.increment_sms_count
    elsif self.is_a?(EmailMessage)
      ## Email message for a list
      list_name = default_list
      self.list = List.find_by_name(default_list)
    else
      ## Keyword list
      list_name = tokens.shift.upcase
      self.list = List.where(use_incoming_keyword: true, name: list_name).first
    end
  end

end
