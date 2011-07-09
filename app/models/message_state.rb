class MessageState < ActiveRecord::Base
  has_many :messages

  def most_recent_messages( count )
    return self.messages.find( :all, :order => "created_at DESC", :limit => count )
  end


  def add_message(message)
    self.messages.push(message)
    self.save
  end
end
