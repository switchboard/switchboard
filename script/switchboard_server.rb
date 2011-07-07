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
  begin
    incoming.handle_messages!
  rescue
    puts("incoming messages -- failure")
  end 
  begin
    outgoing.handle_messages!
  rescue
    puts("outgoing messages -- failure")
  end
  sleep(SLEEP_TIME)
end

