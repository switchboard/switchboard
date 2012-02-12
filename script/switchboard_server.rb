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
  puts("\nMessage processing has started.")
  incoming_success = true
  outgoing_success = true
  begin
    incoming.handle_messages!
  rescue StandardError => e
    puts("incoming messages -- failure.")
    puts("error was: " + e.inspect )
    puts("error backtrace: " + e.backtrace.inspect )
    puts("error was: " + e.inspect )
    puts("e: " + e.to_s )
    incoming_sucess = false
  end 

  puts (" ** Processed incoming messages.")
  
  begin
    outgoing.handle_messages!
  rescue StandardError => e
    puts("outgoing messages -- failure")
    puts("error was: " + e.inspect )
    puts("error backtrace: " + e.backtrace.inspect )
    puts("error was: " + e.inspect )
    puts("caller was: " + callin.in)
    puts("e: " + e.to_s )
    outgoing_success =false
  end

  puts (" ** Processed outgoing messages.")
  
  if (incoming_success and outgoing_success) 
    puts(" ** Updating daemon status timestamp.")
    ## update timestamp in daemonstatus table
    d = DaemonStatus.find(:first, :order => "updated_at desc", :limit => 1)
    if (d == nil) 
      d = DaemonStatus.create(:active => true)
    end
    d.updated_at_will_change!
    d.active = true 
    d.save
  end
  sleep(SLEEP_TIME)
end

