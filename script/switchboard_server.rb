# i'm currently running this as
# script/console < script/test/scriptname.rb
# script/task_server.rb
#!/usr/bin/env ruby
#
# Switchboard Background Task Server
#
# Main algorithm is daemon process that runs every XX seconds, wakes up and
# looks for incoming or outgoing messages.

ENV['RAILS_ENV'] = ARGV.first || ENV['RAILS_ENV'] || 'production'

path = File.dirname(__FILE__) + '/../config/environment.rb'
puts("path: " + path )
require path
#if RAILS_ENV == "development" or RAILS_ENV == "test": 
SLEEP_TIME = 10
#else
#  SLEEP_TIME = 60
#end
print("Running switchboard server.\n")

require 'switchboard/message_handlers/incoming/demo_list_message_handler.rb'
require 'switchboard/message_handlers/outgoing/twilio_or_email_outgoing_message_handler.rb'

incoming = Switchboard::MessageHandlers::Incoming::DemoListMessageHandler.new

outgoing = Switchboard::MessageHandlers::Outgoing::TwilioOrEmailOutgoingMessageHandler.new


loop do
  incoming.handle_messages!
  outgoing.handle_messages!
  sleep(SLEEP_TIME)
end

