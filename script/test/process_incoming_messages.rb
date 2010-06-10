# i'm currently running this as
# script/console < script/test/scriptname.rb

outgoing_state = MessageState.find_or_create_by_name('outgoing');
incoming_state = MessageState.find_or_create_by_name('incoming');
outgoing_state = MessageState.find_or_create_by_name('handled');
outgoing_state = MessageState.find_or_create_by_name('sent');

require 'switchboard/message_handlers/incoming/demo_list_message_handler.rb'
require 'switchboard/message_handlers/outgoing/twilio_or_email_outgoing_message_handler.rb'

incoming = Switchboard::MessageHandlers::Incoming::DemoListMessageHandler.new

outgoing = Switchboard::MessageHandlers::Outgoing::TwilioOrEmailOutgoingMessageHandler.new
while true
    incoming.handle_messages!
    outgoing.handle_messages!
    sleep(1)
end
