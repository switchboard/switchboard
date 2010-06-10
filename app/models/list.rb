class List < ActiveRecord::Base

  validates_presence_of :name
  has_many :list_memberships
  has_many :phone_numbers, :through => :list_memberships
  belongs_to :user 

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

  def create_outgoing_message(num, body)

      if ( num.provider_email != '' and num.provider_email != nil  )
        message = EmailMessage.new
        message.to = num.number + "@" + num.provider_email
        message.from = self.name + "@mmptext.info"
      else
        message = TwilioMessage.new
        message.to = num.number
      end

      message.body = body

      message_state = MessageState.find_by_name("outgoing")
      message_state.messages.push(message)
      message_state.save!
  end

end
