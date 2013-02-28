#!/usr/bin/env ruby
# i'm currently running this as
# script/console < lib/process_outgoing_queue.rb

# You might want to change this
ENV["RAILS_ENV"] ||= "development"
#production"

require File.dirname(__FILE__) + "/../../config/environment"

require 'switchboard/message_handlers/outgoing/twilio_outgoing_message_handler.rb'

$running = true
Signal.trap("TERM") do 
  $running = false
end

while($running) do
  
  # Replace this with your code
  ActiveRecord::Base.logger.info "This daemon is still running at #{Time.now}.\n"
# i'm currently running this as
# script/console < lib/process_outgoing_queue.rb

h = Switchboard::MessageHandlers::Outgoing::TwilioOutgoingMessageHandler.new
h.handle_messages!
  
  sleep 10
end
