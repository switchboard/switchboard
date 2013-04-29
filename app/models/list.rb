require 'csv'

class List < ActiveRecord::Base
  has_many :list_memberships, dependent: :destroy
  has_many :phone_numbers, through: :list_memberships

  has_many :messages, dependent: :destroy, order: 'created_at DESC'
  belongs_to :organization

  attr_accessible :name, :custom_welcome_message, :all_users_can_send_messages, :open_membership
  attr_accessible :use_welcome_message, :welcome_message, :incoming_number
  attr_accessible :text_admin_with_response, :add_list_name_header, :identify_sender, :csv_file

  has_attached_file :csv_file


  validates_format_of :name, :with => /^\S+$/, :message => "List name cannot contain spaces"
  validates :name, uniqueness: true
  validates :organization, presence: true
  validates_format_of :incoming_number, with: /^\d{10}$/, message: "Phone number must contain 10 digits with no extra characters", allow_blank: true


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

  def admins
    self.list_memberships.select{ |mem| mem.is_admin? }.collect{ |admin| admin.phone_number }
  end

  def number_is_admin?(phone_number)
    number = list_memberships.find_by_phone_number_id(phone_number.id)

    if number
      number.is_admin?
    else
      raise 'phone number is not a member of list'
    end
  end

  def toggle_admin(phone_number)
    self.number_is_admin?(phone_number) ? self.remove_admin(phone_number) : self.add_admin(phone_number)
  end

  def remove_admin(phone_number)
    membership = list_memberships.find_by_phone_number_id(phone_number.id)
    membership.update_column(:is_admin, false)
  end

  def add_admin(phone_number)
    membership = list_memberships.find_by_phone_number_id(phone_number.id)
    membership.update_column(:is_admin, true)
  end

  def most_recent_messages(count)
    messages.sent.limit(count)
  end

  def create_email_message(num)
    message = EmailMessage.new
    message.to = num.number + "@" + num.provider_email
    message.from = self.name + '@mmptext.info'
    message
  end

  def create_twilio_message(num)
    message = TwilioMessage.new
    message.to = num.number
    message
  end

  def create_outgoing_message(num, body)
    # once there are other external gateways, or not all phone numbers
    # support the commercial gateway, this gets more complicated
    if ( num.can_receive_email? and self.allow_email_gateway? and
      ( (! self.allow_commercial_gateway?) or self.prefer_email ))
      message = create_email_message(num)
    elsif (self.allow_commercial_gateway? and num.can_receive_gateway?)
      message = create_twilio_message(num)
    else
      raise "list & subscriber settings make sending message impossible for num: " + num.number
    end

    if self.incoming_number
      message.from = self.incoming_number
    else
      Rails.logger.debug("no incoming number")
    end

    message.body = body
    message.list = self
    message_state = MessageState.find_by_name("outgoing")
    message_state.messages.push(message)
    message_state.save!
  end

  def name=(str)
    self[:name] = str.upcase
  end

  def incoming_number=(str)
    write_attribute(:incoming_number, str.try(:gsub, /[^0-9]/, ''))
  end

  def welcome_message
    custom_welcome_message || default_welcome_message
  end

  # Calculate length; ideally would be dry-ed up
  def calculate_meta_length(from_number)
    meta_length = 0
    meta_length += "[#{name}] ".length if add_list_name_header?
    meta_length += " (#{from_number.name_and_number})".length if add_sender_identity?(from_number)
    meta_length
  end

  def prepare_content(message, from_number)
    # Tokens are generated in message handler;
    # (just an array of words, possibly minus keywords)
    body = message.tokens.join(' ')

    body = "[#{name}] #{body}" if add_list_name_header?

    if add_sender_identity?(from_number)
      body << " (#{from_number.name_and_number})"
    end

    content = [body]
    if (body.length > 160)
      content = split_message_by_160(body)
    end

    content
  end

  def add_sender_identity?(from_number)
    identify_sender? && from_number.contact && from_number.contact.full_name.present?
  end

  def split_message_by_160(str)
    # 160 - 6 characters for message count:  ' (1/2)'
    max_length = 160 - 6
    messages = []
    while(str.length > max_length)
      last_space_pos = str[0..max_length].rindex(' ') || max_length - 1
      split_at = last_space_pos
      messages << str[0..last_space_pos].strip
      str = str[(last_space_pos + 1)..-1]
      str = str ? str.strip : ''
    end
    messages << str unless str.length == 0
    messages.each_with_index.map{|msg, index| msg + " (#{index+1}/#{messages.length})"}
  end

  def handle_send_action(message)
    # Not sure why we're doing this here
    message.sender = message.from_phone_number.contact
    message.save

    if message.from_web? || all_users_can_send_messages? || number_is_admin?(message.from_phone_number)
      message_split = prepare_content(message, from_number)
      phone_numbers.each do |phone_number|
        message_split.each do |body|
          create_outgoing_message(phone_number, body)
        end
      end

    elsif admins.any? && text_admin_with_response?
      admin_msg = "[#{name}] from #{message.from_phone_number.number}"

      if message.sender && message.sender.first_name.present?
        admin_msg << "/ #{message.sender.full_name}"
      end

      admin_msg << '] ' << message.tokens.join(' ')
      admins.each do |admin|
        create_outgoing_message(admin, admin_msg)
      end
    end
  end

  def handle_join_message(message)
    # Handle re-subscribing
    if has_number?(message.from_phone_number)
      create_outgoing_message(message.from_phone_number, "It seems like you are trying to join the list #{name}, but you are already a member.")
    elsif open_membership?

      # Not sure why we do this here necessarily
      if ! message.from_phone_number.contact
        contact = Contact.create()
        contact.phone_numbers << message.from_phone_number
      end

      list_memberships.create!(phone_number_id: message.phone_number.id)

      # Not sure why we do this here, either.
      message.sender = list.from_phone_number.contact
      message.save
    else
      create_outgoing_message(message.from_phone_number, "Sorry, this list is configured as a private list; only the administrator can add new members.")
    end
  end

  def send_welcome_message(phone_number)
    create_outgoing_message( phone_number, welcome_message ) if use_welcome_message?
  end

  protected

    def default_welcome_message
      msg = "Welcome to the '#{self.name}' list.  Unsubcribe by texting 'leave' to this number."
      if self.incoming_number.blank?
        msg = msg + " Respond by texting #{self.name} + your message."
      end
    end

end

