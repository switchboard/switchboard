class Message < ActiveRecord::Base

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
