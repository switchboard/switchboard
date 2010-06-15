# i'm currently running this as
# script/console < lib/process_outgoing_queue.rb
require 'switchboard/message_handlers/outgoing/twilio_outgoing_message_handler.rb'

outgoing_state = MessageState.find_by_name('outgoing')
m = Message.new
m.body = "hello world via the twilio outgoing message handler!"
m.to = '2677024687'
outgoing_state.messages.push(m)
outgoing_state.save

h = Switchboard::MessageHandlers::Outgoing::TwilioOutgoingMessageHandler.new
h.handle_messages!

