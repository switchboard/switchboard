class Message < ActiveRecord::Base

  ## messages can be associated with the user they have been sent to or recieved from
  ## see http://www.spacevatican.org/2008/5/6/creating-multiple-associations-with-the-same-table
  belongs_to  :sender, :class_name => 'User' 
  belongs_to  :recipient, :class_name => 'User'
  belongs_to :list  
  belongs_to :message_state

  def from_email_gateway?
    if (self.from =~ /@/)
      return true
    else
      return false
    end
  end

  def from_web?
    self.from == 'Web'
  end

  ## returns phone number of message sender
  def sender_number
    if self.respond_to? :carrier
      return self[:number]
    else 
      return self[:from]
    end
  end

  # get the name of the sender 
  def from_for_display
    phone_number = PhoneNumber.find_by_number(self[:from])
    if phone_number != nil
      return phone_number.display_number_with_name
    else
      return ''
    end
  end

  ## save an array of 'tokens' (words) from the message that haven't been processed yet
  def tokens=(tokens)
    @tokens = tokens
  end

  def tokens
    @tokens
  end

  scope :within_days, lambda { |within_days|
    {:conditions => ["updated_at #{(within_days.days.ago..Time.now).to_s(:db)}"] }
  }
  
  scope :in_state, lambda { |state_id|
    {:conditions => ['message_state_id = ?', state_id]}
  }

end
