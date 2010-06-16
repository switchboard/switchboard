class List < ActiveRecord::Base

  validates_format_of :name, :with => /^\S+$/, :message => "List name cannot contain spaces"
  validates_uniqueness_of :name
  has_many :list_memberships
  has_many :phone_numbers, :through => :list_memberships
  belongs_to :admin, :class_name => 'PhoneNumber'
 
  has_many :messages, :order => "created_at DESC"

  ## 
  ## TODO: decide if these receive objects or strings or are flexible?
  ## for now: take objects

  def add_phone_number(phone_number)
    return if self.has_number?(phone_number)
    puts "adding number: " + phone_number.number 
    self.save
    self.list_memberships.create! :phone_number_id => phone_number.id
    if(self.use_welcome_message?)
      puts "has welcome message, and creating outgoing message"
      welcome_message = self.custom_welcome_message
      create_outgoing_message( phone_number, welcome_message )
    end 
  end

  def remove_phone_number(phone_number)
    return unless self.has_number?(phone_number)
    self.list_memberships.find_by_phone_number_id(phone_number.id).destroy
  end

  def has_number?(phone_number)
    self.list_memberships.exists?(:phone_number_id => phone_number.id)
  end

  def phone_numbers
    numbers =  []
    self.list_memberships.each do |mem|
      numbers << mem.phone_number
    end
    return numbers
  end


  def most_recent_message
    return ( self.messages.count > 0 ? self.messages[0] : nil )
  end

  def most_recent_messages( count )
    return self.messages.find( :all, :order => "created_at DESC", :limit => count )
  end

  def most_recent_message_from_user(user)
    self.messages.find( :all, :conditions => { :sender_id => user.id }, :order => "created_at DESC", :limit => 1 )
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

    message.body = body

    message_state = MessageState.find_by_name("outgoing")
    message_state.messages.push(message)
    message_state.save!
  end

  def name=(value)
    self[:name] = value.upcase!
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

  protected

    def default_welcome_message
      "Welcome to the '#{self.name}' list! To unsbuscribe, text '....'. To receive help, text '....'" 
    end

end
