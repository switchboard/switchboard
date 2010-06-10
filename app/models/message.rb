class Message < ActiveRecord::Base

  def from_email_gateway?
    if (self.from =~ /@/)
      return true
    else
      return false
    end
  end

end
