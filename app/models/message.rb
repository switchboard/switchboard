class Message < ActiveRecord::Base

  ## messages can be associated with the user they have been sent to or recieved from
  ## see http://www.spacevatican.org/2008/5/6/creating-multiple-associations-with-the-same-table
  belongs_to  :sender, :class_name => 'User' 
  belongs_to  :recipient, :class_name => 'User'
  belongs_to :list  

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

end
