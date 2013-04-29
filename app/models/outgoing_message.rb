class OutgoingMessage
  @queue = :outgoing

  def self.perform(message_id, phone_number_id, message_body)
    
  end
end