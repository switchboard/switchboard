class Message < ActiveRecord::Base
  include AASM

  belongs_to :sender, :class_name => 'Contact'
  belongs_to :from_phone_number, class_name: 'PhoneNumber'
  belongs_to :recipient, :class_name => 'Contact'
  belongs_to :list
  belongs_to :message_state

  attr_accessible :from, :body

  aasm do
    state :incoming, initial: true
    state :processing
    state :in_send_queue
    state :handled
    state :sent
    state :failure
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

    event :queue_to_send do
      before do
        self.queued_at = Time.now
      end
      transitions from: :processing, to: :in_send_queue
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

  end

  before_create :set_from_number, :set_list
  after_create :enqueue_incoming

  scope :recent, order('created_at DESC')

  def self.within_days(num_days)
    where('updated_at > ?', num_days.days.ago)
  end

  def self.for_display
    where(aasm_state: ['in_send_queue', 'sent'])
  end

  def self.single_most_recent_from_contact(contact_id)
    where(sender_id: contact_id).first
  end


  def from_email_gateway?
    from =~ /@/
  end

  def from_web?
    from == 'Web'
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

      if first_token == 'join'
        list.handle_join_message(self)
        mark_handled!
      elsif first_token == 'leave' || first_token == 'quit'
        list.handle_leave_message(self)
        mark_handled!
      else
        # Need to decide where we're handling message state;
        # handle_send_action is only action that returns true/false

        if list.handle_send_action(self)
          queue_to_send!
        else
          # Message can't be sent to list or to admins;
          # should this throw an exception?
          mark_failure!
        end
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

    # Remove all but digits and take last 10
    to_number = to.to_s.gsub(/[^0-9]/, '')
    to_number = to_number[-10..-1] || to_number

    if self.list = List.find_by_incoming_number(to_number)
      ## Non-keyword list (assigned phone number)
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
