require 'switchboard/message_handlers/outgoing_message_handler.rb'
require 'twilio/twilio_sender'

module Switchboard::MessageHandlers::Outgoing
    class TwilioOutgoingMessageHandler < Switchboard::MessageHandlers::OutgoingMessageHandler
        def handle_messages!()
            puts "Handling outgoing messages."
            sender = Twilio::TwilioSender.new()
            ## these should come from an array of output connectors (tuple of state & conditions)
            output_state_name = 'sent'
            output_state_conditions = {}
            outgoing_state = MessageState.find_by_name(output_state_name)
            outgoing_states = [ outgoing_state ]
            ## should be  outgoing_states.each |state,conditions| do 
            messages_to_handle.each do |message|
                puts "About to send a message.  To: " + message.to
                puts "Outgoing message body: " + message.body
                sender.send_sms( message.to, message.body )
                outgoing_state.messages.push(message) 
                outgoing_state.save
            end
        end
    end
end
