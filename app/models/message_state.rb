class MessageState < ActiveRecord::Base
  has_many :messages

  def add_message(message)
    self.messages.push(message)
    self.save
  end
end
