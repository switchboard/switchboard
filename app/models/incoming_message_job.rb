class IncomingMessageJob
  @queue = :incoming

  def self.perform(message_id)
    message = Message.incoming.find(message_id)
    message.mark_processing!
    
    ## Disabling this temporarily
    # survey_state = SurveyState.where(active: true, phone_number_id: 1).first
    # 
    # if ( survey_state != nil )
    #   puts("handle survey response.")
    #   survey_state.handle_message(message.from_phone_number, message.body)
    #   handled_state.messages.push(message)
    #   handled_state.save
    #   next
    # end

    message.process
  end
end