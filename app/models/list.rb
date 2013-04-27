require 'csv'

class List < ActiveRecord::Base

  has_many :list_memberships
  has_many :phone_numbers, :through => :list_memberships

  has_many :messages, order: 'created_at DESC'
  belongs_to :organization

  attr_accessible :name, :custom_welcome_message, :all_users_can_send_messages, :open_membership
  attr_accessible :use_welcome_message, :welcome_message, :incoming_number
  attr_accessible :text_admin_with_response, :add_list_name_header, :identify_sender, :csv_file

  has_attached_file :csv_file


  validates_format_of :name, :with => /^\S+$/, :message => "List name cannot contain spaces"
  validates :name, uniqueness: true
  validates :organization, presence: true
  validates_format_of :incoming_number, with: /^\d{10}$/, message: "Phone number must contain 10 digits with no extra characters", allow_blank: true

  ## 
  ## TODO: decide if these receive objects or strings or are flexible?
  ## for now: take objects

  def add_phone_number(phone_number)
    if has_number?(phone_number) || ! phone_number.try(:id)
      puts("phone_number is ill formed in add_phone_number")
      return
    end

    list_memberships.create! :phone_number_id => phone_number.id
    if(self.use_welcome_message?)
      puts "has welcome message, and creating outgoing message"
      welcome_message = self.custom_welcome_message
      create_outgoing_message( phone_number, welcome_message )
    end 
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
        add_phone_number(phone_number)
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
    phone_number.try(:id) && list_memberships.exists?(phone_number_id: phone_number.id)
  end
 
  def admins
    self.list_memberships.select{ |mem| mem.is_admin? }.collect{ |admin| admin.phone_number }
  end

  def number_is_admin?(phone_number)
    number = list_memberships.find_by_phone_number_id(phone_number.id)

    if number
      number.is_admin?
    else
      raise ArgumentError("phone number is not a member of list")
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
    messages.where(message_state_id: MessageState.find_by_name('handled').id).limit(count)
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
    # once there are other external gateways, or not all phone numbers support the commercial gateway
    # this gets more complicated 

    if ( num.can_receive_email? and self.allow_email_gateway? and
      ( (! self.allow_commercial_gateway?) or self.prefer_email ))
      message = create_email_message(num)
    elsif (self.allow_commercial_gateway? and num.can_receive_gateway?)
      message = create_twilio_message(num)
    else 
      raise "list & subscriber settings make sending message impossible for num: " + num.number
    end
  
    if self.incoming_number
      puts("sending message to list with incoming number: " + self.incoming_number )
      message.from = self.incoming_number 
    else
      puts("no incoming number")
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

  def prepare_content(message, from_number)
    body = ''
    body = "[#{name}] " if add_list_name_header?

    # Tokens are generated in message handler;
    # (just an array of words, possibly minus keywords)
    body << message.tokens.join(' ')

    if identify_sender? && from_number.contact && from_number.contact.full_name.present?
      body << " (#{message.from_for_display})"
    end

    body
  end

  def handle_send_action(message, from_number)
    message.list = self
    message.sender = from_number.contact
    message.save
    if message.from_web? || all_users_can_send_messages? || number_is_admin?(from_number)
      content = prepare_content(message, from_number)
      logger.info("sending message: " + content + ", to: " + self[:name])
      phone_numbers.each do |phone_number|
        content = prepare_content(message, from_number)
        logger.debug("sending message: #{content}, to: #{phone_number.number}")
        create_outgoing_message(phone_number, content)
      end

    elsif admins.any? && text_admin_with_response?
      admin_msg = "[#{name}] from #{from_number.number}"

      if from_number.contact && from_number.contact.first_name.present?
        admin_msg << "/ #{from_number.contact.first_name} #{from_number.contact.last_name}"
      end

      admin_msg << '] ' << message.tokens.join(' ')
      admins.each do |admin|
        create_outgoing_message(admin, admin_msg)
      end
    end
  end

  def handle_join_message(message, num) 
    puts(" ** Handling join message.\n")
    if self.has_number?(num)
      self.create_outgoing_message( num, "It seems like you are trying to join the list '" + self[:name] + "', but you are already a member.")
    else
      if (self.open_membership)
    	puts(" ** List is open, adding contact.")
        message.list = self
        if !num.contact
          puts " ** Creating contact for num: " + num.number
          num.contact = Contact.create(:password => 'abcdef981', :password_confirmation => 'abcdef981')
          num.save!
          num.contact.save!
        end
        self.add_phone_number(num)

        message.sender = num.contact
        message.save
        self.save 
      else ## not list.open_membership
        self.create_outgoing_message( num, "I'm sorry, but this list is configured as a private list and only the administrator can add new members.")
      end
    end
  end

  def self.top_five(options)
    # how do we determine the top five lists? get random five for now!
    topfive = List.limit(5)

    if options[:remove_list_id]
      topfive.where('id NOT IN (?)', options[:remove_list_id])
    end

    topfive
  end

  def self.more_than_five
    List.count > 5
  end

  protected

    def default_welcome_message
      msg = "Welcome to the '#{self.name}' list.  Unsubcribe by texting 'leave' to this number." 
      if self.incoming_number.blank?
        msg = msg + " Respond by texting #{self.name} + your message."
      end
    end

end

