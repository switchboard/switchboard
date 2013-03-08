class Message < ActiveRecord::Base

  ## messages can be associated with the user they have been sent to or recieved from
  ## see http://www.spacevatican.org/2008/5/6/creating-multiple-associations-with-the-same-table
  belongs_to  :sender, :class_name => 'User' 
  belongs_to  :recipient, :class_name => 'User'
  belongs_to :list  
  belongs_to :message_state

  attr_accessible :from, :body

  ## save an array of 'tokens' (words) from the message that haven't been processed yet
  attr_accessor :tokens

  def self.within_days(num_days)
    where('updated_at > ?', num_days.days.ago)
  end

  def self.in_state(state_id)
    where(message_state_id: state_id)
  end

  def self.most_recent(count)
    in_state(3).limit(count)
  end

  def self.single_most_recent_from_user(user_id)
    where(sender_id: user_id).first
  end


  def from_email_gateway?
    from =~ /@/
  end

  def from_web?
    from == 'Web'
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
    PhoneNumber.find_by_number(from).try(:name_and_number)
  end

end
