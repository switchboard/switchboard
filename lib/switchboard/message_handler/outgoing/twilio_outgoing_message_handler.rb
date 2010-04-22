require 'switchboard/message_handler/outgoing_message_handler.rb'
require 'twilio/twilio_sender'

module Switchboard::MessageHandler::Outgoing
    class TwilioOutgoingMessageHandler < OutgoingMessageHandler
        def handle_messages!()
            sender = Twilio::TwilioSender.new()
            messages_to_handle.each do |message|
                sender.send_sms( message.to, message.body )
            end
        end
    end
end
