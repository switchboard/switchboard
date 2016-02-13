require 'csv'

class List < ActiveRecord::Base
  include MonthlyCountable

  has_many :list_memberships, dependent: :destroy
  has_many :phone_numbers, through: :list_memberships

  has_many :list_memberships, dependent: :destroy
  has_many :phone_numbers, through: :list_memberships
  has_many :admin_phone_numbers, through: :list_memberships, source: :phone_number,
           conditions: ['list_memberships.is_admin = ?', true]

  has_many :messages, order: 'created_at DESC'
  has_many :sent_counts, as: :countable, dependent: :destroy
  belongs_to :organization
  belongs_to :incoming_phone_number

  attr_accessible :name, :custom_welcome_message, :all_users_can_send_messages, :open_membership,
                  :use_welcome_message, :welcome_message, :default_locale, :incoming_phone_number_id,
                  :text_admin_with_response, :require_admin_confirmation, :add_list_name_header, :identify_sender, :csv_file

  has_attached_file :csv_file

  validates_format_of :name, :with => /^\S+$/, :message => "List name cannot contain spaces"
  validates :name, uniqueness: {scope: :deleted}, unless: Proc.new { |list| list.deleted? }
  validates :organization, presence: true
  # validates_format_of :incoming_number, with: /^\d{10}$/, message: "Phone number must contain 10 digits with no extra characters", allow_blank: true

  default_scope where(deleted: false)
  scope :no_incoming_number, -> { where("incoming_phone_number_id is null") }
  scope :with_incoming_number, -> { where("incoming_phone_number_id is not null") }

  def name=(str)
    self[:name] = str.upcase
  end

  def import_from_attachment
    raise 'CSV File was not uploaded' unless csv_file
    errors = []
    success_count = 0

    CSV.foreach(csv_file.path) do |row|
      begin
        raise 'Not enough fields' if row.length < 4
        first_name, last_name, email = row[0..2]
        number = row[3].try(:gsub, /\D/, '')

        unless phone_number = PhoneNumber.find_by_number(number)
          if email =~ /@/
            email.gsub!(/\s/, '')
            contact = Contact.find_or_create_by_email(first_name: first_name, last_name: last_name, email: email)
          else
            contact = Contact.create!(first_name: first_name, last_name: last_name)
          end
          phone_number = contact.phone_numbers.create!(number: number)
        end
        list_memberships.create!(phone_number_id: phone_number.id)

        success_count += 1
      rescue => exception
        errors << row.join(' ') + ': ' + exception.message
      end
    end

    {errors: errors, success_count: success_count}
  end

  def remove_phone_number(phone_number)
    return unless self.has_number?(phone_number)
    list_memberships.find_by_phone_number_id(phone_number.id).destroy
  end

  def has_number?(phone_number)
    list_memberships.where(phone_number_id: phone_number.id).exists?
  end

  def number_is_admin?(phone_number)
    list_memberships.admin.where(phone_number_id: phone_number.id).exists?
  end

  def toggle_admin(phone_number)
    number_is_admin?(phone_number) ? remove_admin(phone_number) : add_admin(phone_number)
  end

  def remove_admin(phone_number)
    membership = list_memberships.find_by_phone_number_id(phone_number.id)
    membership.update_column(:is_admin, false) if membership
  end

  def add_admin(phone_number)
    membership = list_memberships.find_by_phone_number_id(phone_number.id)
    membership.update_column(:is_admin, true) if membership
  end

  def most_recent_messages(count)
    messages.for_display.limit(count)
  end

  # Message id is passed to keep outgoing message counts;
  # It does not need to be passed for administrative messages
  def create_outgoing_message(phone_number, body, message_id = nil, outgoing_count = nil)
    if phone_number.can_receive_email? && allow_email_gateway? &&
                                  (! allow_commercial_gateway? || prefer_email? )
      to = "#{phone_number.number}@#{phone_number.provider_email}"
      from = "#{name}@mmptext.info"
    elsif allow_commercial_gateway? && phone_number.can_receive_gateway? && incoming_phone_number.present?
      to = phone_number.number
      from = incoming_phone_number.phone_number
    else
      raise "List & subscriber settings make sending message impossible for number #{phone_number.number} [list: #{name}]."
    end

    Resque.enqueue(OutgoingMessageJob, id, to, from, body, message_id, outgoing_count)
  end

  def soft_delete
    update_column(:deleted, true)
  end

  # Message Counts
  # ====================

  def sent_count
    messages.sent.size
  end

  def increment_sms_count
    $redis.incr redis_count_key
  end

  def self.increment_sms_count(list_id)
    $redis.incr "list_out_#{list_id}"
  end

  def current_month_sms
    ($redis.get(redis_count_key) || 0).to_i
  end

  def clear_current_sms
    $redis.set(redis_count_key, 0)
  end

  def redis_count_key
    "list_out_#{id}"
  end

  # Using current-month for count; list_out_123 is reset monthly after count
  alias_method :sms_count_for_rollup, :current_month_sms

  # ====================
  def welcome_message(locale = nil)
    custom_welcome_message.present? ? custom_welcome_message : default_welcome_message(locale)
  end

  # Calculate length; ideally would be dry-ed up
  def calculate_meta_length(from_number)
    meta_length = 0
    meta_length += "[#{name}] ".length if add_list_name_header?
    meta_length += " (#{from_number.name_and_number})".length if add_sender_identity?(from_number)
    meta_length
  end

  def prepare_content(message)
    # Tokens are generated in message handler;
    # (just an array of words, possibly minus keywords)
    body = message.tokens.join(' ')

    body.prepend("[#{name}] ") if add_list_name_header?

    if add_sender_identity?(message.from_phone_number)
      body << " (#{message.from_phone_number.name_and_number})"
    end

    if (body.length > 160)
      split_message_by_160(body)
    else
      [body]
    end
  end

  def add_sender_identity?(from_number)
    from_number && identify_sender? && from_number.contact && from_number.contact.full_name.present?
  end

  def split_message_by_160(str)
    # 160 - 6 characters for message count:  ' (1/2)'
    max_length = 160 - 6
    messages = []
    while(str.length > max_length)
      last_space_pos = str[0..max_length].rindex(' ') || max_length - 1
      messages << str[0..last_space_pos].strip
      str = str[(last_space_pos + 1)..-1]
      str = str.try(:strip) || ''
    end
    messages << str unless str.length == 0
    messages.each_with_index.map{|msg, index| msg + " (#{index+1}/#{messages.length})"}
  end

  def can_send_message?(message)
    message.from_web? || all_users_can_send_messages? || (! require_admin_confirmation? && number_is_admin?(message.from_phone_number))
  end

  def message_needs_confirmation?(message)
    ! message.from_web? && number_is_admin?(message.from_phone_number) && require_admin_confirmation?
  end

  def handle_send_action(message)
    # TODO it appears that even non list-members can send messages to lists?
    # Not sure if that's a bug or a feature
    message_split = prepare_content(message)
    outgoing_count = phone_numbers.size * message_split.length
    message.update_column(:outgoing_total, outgoing_count)
    message_split.each do |body|
      phone_numbers.each do |phone_number|
        create_outgoing_message(phone_number, body, message.id, outgoing_count)
      end
    end
  end

  def can_admin_message?(message)
    text_admin_with_response? && admin_phone_numbers.any?
  end

  def send_admin_message(message)
    admin_msg = "[#{name} from #{message.from_phone_number.number}"

    if message.sender && message.sender.full_name.present?
      admin_msg << " / #{message.sender.full_name}"
    end

    admin_msg << '] ' << message.tokens.join(' ')
    send_message_to_admins(admin_msg)
  end

  def send_confirmation_message(message)
    admin_msg = "[#{name}]"
    admin_msg << message.sender_name_or_number
    admin_msg << " sent a message that needs confirmation. Respond with 'confirm' within #{Settings.message_confirmation_time} minutes to send message."
    send_message_to_admins(admin_msg)
  end

  def send_message_to_admins(admin_msg)
    admin_phone_numbers.each do |admin_phone_number|
      create_outgoing_message(admin_phone_number, admin_msg)
    end
  end

  def handle_leave_message(message, locale = :en)
    if has_number?(message.from_phone_number)
      remove_phone_number(message.from_phone_number)
      create_outgoing_message(message.from_phone_number, I18n.t('list_responses.removed', name: name, locale: locale))
    else
      create_outgoing_message(message.from_phone_number, I18n.t('list_responses.remove_not_subscribed', name: name, locale: locale))
    end
  end

  def handle_join_message(message, locale = :en)
    # Handle re-subscribing
    if has_number?(message.from_phone_number)
      create_outgoing_message(message.from_phone_number,I18n.t('list_responses.join_already_subscribed', name: name, locale: locale))
    elsif open_membership?

      # Not sure why we do this here necessarily
      if ! message.from_phone_number.contact
        contact = Contact.create()
        contact.phone_numbers << message.from_phone_number
      end

      list_memberships.create!(phone_number_id: message.from_phone_number.id, join_locale: locale)
    else
      create_outgoing_message(message.from_phone_number, I18n.t('list_responses.join_private', locale: locale))
    end
  end

  def handle_confirmation_message(message, locale = :en)
    if to_confirm = messages.needs_confirmation.where('created_at > ?', Settings.message_confirmation_time.minutes.ago).first
      to_confirm.mark_confirmed!
      handle_send_action(to_confirm)
    else
      admin_msg = "[#{name}] "
      admin_msg << message.sender_name_or_number
      admin_msg << " sent a message to confirm a pending message, but there are no recent messages that need confirmation."
      send_message_to_admins(admin_msg)
    end
  end

  def send_welcome_message(phone_number, locale = nil)
    create_outgoing_message(phone_number, welcome_message(locale || default_locale)) if use_welcome_message?
  end

  protected

  def default_welcome_message(locale)
    I18n.t('list_responses.default_welcome', name: name, locale: locale || default_locale)
  end

end

