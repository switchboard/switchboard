# i'm currently running this as
# script/console < script/test/scriptname.rb

outgoing_state = MessageState.find_or_create_by_name('outgoing');
incoming_state = MessageState.find_or_create_by_name('incoming');
outgoing_state = MessageState.find_or_create_by_name('handled');
outgoing_state = MessageState.find_or_create_by_name('sent');

require 'switchboard/message_handlers/incoming/demo_list_message_handler.rb'
require 'switchboard/message_handlers/outgoing/twilio_outgoing_message_handler.rb'
incoming_state = MessageState.find_by_name('incoming')
#m = Message.new
#m.body = "demo This is the second thingo to the dmeo list"
#m.from = '2679777848'
#incoming_state.messages.push(m)
#incoming_state.save

incoming = Switchboard::MessageHandlers::Incoming::DemoListMessageHandler.new
incoming.handle_messages!

outgoing = Switchboard::MessageHandlers::Outgoing::TwilioOutgoingMessageHandler.new
outgoing.handle_messages!

