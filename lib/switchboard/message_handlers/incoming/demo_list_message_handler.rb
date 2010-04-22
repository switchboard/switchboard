require 'switchboard/message_handlers/incoming_message_handler.rb'
require 'twilio/twilio_sender'

module Switchboard::MessageHandlers::Outgoing
    class DemoListMessageHandler < Switchboard::MessageHandlers::IncomingMessageHandler
        def handle_messages!()
            ## should be  outgoing_states.each |state,conditions| do 
            messages_to_handle.each do |message|

                ## match text
                ## add to list if appropriate
                ## send out message to list if appropriate
            end
        end
    end
end
