class List < ActiveRecord::Base

  validates_presence_of :name
  has_many :list_memberships
  has_many :phone_numbers, :through => :list_memberships
  belongs_to :user 
  has_many :messages, :order => "created_at DESC"

  ## 
  ## TODO: decide if these receive objects or strings or are flexible?
  ## for now: take objects

  def add_phone_number(phone_number)
    return if self.has_number?(phone_number)
    self.list_memberships.create! :phone_number_id => phone_number.id
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
    self.messages.find( :all, :conditions => [ :user_id => user.id ], :order => "created_at DESC", :limit => 1 )
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
    elsif (self.allow_email_gateway? and num.can_receive_gateway?)
      message = create_twilio_message(num)
    else 
      raise "list & subscriber settings make sending message impossible for num: " + num.to
    end

    message.body = body

    message_state = MessageState.find_by_name("outgoing")
    message_state.messages.push(message)
    message_state.save!
  end

  def welcome_message
    self.use_welcome_message && self.welcome_message_text
  end
  
  protected
    def welcome_message_text
      self.custom_welcome_message || self.default_welcome_message
    end

    def default_welcome_message
      "Welcome to the '#{self.name}' list! To unsbuscribe, text '....'. To receive help, text '....'" 
    end

end
