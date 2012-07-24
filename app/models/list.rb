class List < ActiveRecord::Base

  validates_format_of :name, :with => /^\S+$/, :message => "List name cannot contain spaces"
  validates_uniqueness_of :name
  validates_format_of :incoming_number, :with => /^\d{10}$/, :message => "Phone number must contain 10 digits with no extra characters", :allow_blank => true
  has_many :list_memberships
  has_many :phone_numbers, :through => :list_memberships

  has_many :messages, :order => "created_at DESC"

  has_many :attachments

  attr_accessible :name, :list_type, :join_policy

  ## 
  ## TODO: decide if these receive objects or strings or are flexible?
  ## for now: take objects

  def add_phone_number(phone_number)
    if (self.has_number?(phone_number) or phone_number == nil or phone_number.id == nil)
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


  def import_from_attachment(attachment_id)
    return unless csv = self.attachments.find(attachment_id)
    errors = []
    successes = 0
    FasterCSV.parse(DbFile.find(csv.db_file_id).data) do |row|
      email = row[2]
      number = row[3]
      user_hash = {:first_name => row[0], :last_name => row[1], :password => 'password', :password_confirmation => 'password'}
      number.gsub!(/\D/, '') if number;
      begin
        raise 'Not enough fields' if row.length < 4
        raise 'Phone number invalid' if row[3] !~ /\d+/
        if ! phone_number = PhoneNumber.find_by_number(number)
          if email =~ /@/
            email.gsub!(/\s/, '') unless email.blank?
            user = User.find_or_create_by_email(user_hash.merge!(:email => email))
          else
            user = User.new(user_hash)
            user.save!
          end
          phone_number = PhoneNumber.new(:number => number, :user_id => user.id)
          phone_number.save! 
        end
        self.add_phone_number(phone_number)
        successes = successes.next
      rescue
        errors << row.join(',') + ' :: ' + $!
      end
    end
    return {:errors => errors, :successes => successes};
  end

  def remove_phone_number(phone_number)
    return unless self.has_number?(phone_number)
    list_memberships.find_by_phone_number_id(phone_number.id).destroy
  end

  def has_number?(phone_number)
    list_memberships.exists?(:phone_number_id => phone_number.id)
  end
 
  def admins
    list_memberships.collect { |mem| 
      mem.phone_number if mem.is_admin?
    }
  end

  def number_is_admin?(phone_number)
    number = list_memberships.find_by_phone_number_id(phone_number.id)

    if number != nil
      number.is_admin?
    end
  end
 
  def toggle_admin(phone_number)
    self.number_is_admin?(phone_number) ? self.remove_admin(phone_number) : self.add_admin(phone_number)
  end

  def remove_admin(phone_number)
    list_memberships.find_by_phone_number_id(phone_number.id).update_attributes!(:is_admin => false)
  end

  def add_admin(phone_number)
    list_memberships.find_by_phone_number_id(phone_number.id).update_attributes!(:is_admin => true)
  end

  def phone_numbers
    numbers =  []
    list_memberships.each do |mem|
      numbers << mem.phone_number
    end
    return numbers
  end

  def create_email_message(num)
    message = EmailMessage.new
    message.to = num.number + "@" + num.provider_email
    message.from = self.name + "@mmptext.info"
    return message
  end

  def create_twilio_message(num)
    message = TwilioMessage.new
    message.to = num.number
    return message
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

  def name=(value)
    upcaseValue = value.upcase
    if self[:name] != upcaseValue
      self[:name] = upcaseValue
    end
  end

  ### these methods make editing lists easier
  def welcome_message
    self.custom_welcome_message || self.default_welcome_message
  end
  
  def welcome_message=(message)
    self.update_attribute('custom_welcome_message', message)
  end

  def list_type
    self.all_users_can_send_messages ? 'discussion' : 'announcement'
  end

  def list_type=(type)
    self.update_attribute('all_users_can_send_messages', (type == 'discussion'))
  end

  def join_policy
    self.open_membership ? 'open' : 'closed'
  end

  def join_policy=(policy)
    self.update_attribute("open_membership", (policy == 'open'))
  end
  ### /these methods make editing lists easier


  def prepare_content(message, num)
    ##?TODO: add config about initial list name prefix
    body = ''

    if (self.add_list_name_header)
      body = body + '[' + self[:name] + '] '
    end

    body = body + message.tokens.join(' ')
    if (self.identify_sender && num.user != nil && ! num.user.full_name != ''  )
      body += " (" + message.from_for_display + ")"
    end

    body
  end

  def handle_send_action(message, num)
    message.list = self 
    message.sender = num.user
    message.save
    if (message.from_web? or self.all_users_can_send_messages? or self.number_is_admin?(num))
      content = self.prepare_content(message, num)
      logger.info("sending message: " + content + ", to: " + self[:name])
      self.phone_numbers.each do |phone_number|
        content = prepare_content(message, num)
        logger.debug("sending message: " + content + ", to: " + phone_number.number )
        self.create_outgoing_message(phone_number, content)
      end
    else
      if (!self.admins.empty? and self.text_admin_with_response)
        admin_msg = '[' + self[:name] + ' from '
        admin_msg +=  num.number.to_s

        if ( num.user != nil and (! num.user.first_name.blank?) )
          admin_msg += "/ " + num.user.first_name.to_s + " " + num.user.last_name.to_s
        end

        admin_msg += '] '
        admin_msg += tokens.join(' ')
        self.admins.each do |admin|
          self.create_outgoing_message(admin, admin_msg )
        end
      end
    end
  end

  def handle_join_message(message, num) 
    puts(" ** Handling join message.\n")
    if self.has_number?(num)
      self.create_outgoing_message( num, "It seems like you are trying to join the list '" + self[:name] + "', but you are already a member.")
    else
      if (self.open_membership)
    	puts(" ** List is open, adding user.")
        message.list = self
        if (num.user == nil)
          puts " ** Creating user for num: " + num.number
          num.user = User.create(:password => 'abcdef981', :password_confirmation => 'abcdef981')
          num.save!
          num.user.save!
        end
        self.add_phone_number(num)

        message.sender = num.user
        message.save
        self.save 
        self.create_outgoing_message(num, self.welcome_message )
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

