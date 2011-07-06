require 'switchboard/message_handlers/outgoing_message_handler.rb'
require 'twilio/twilio_sender'
require 'net/smtp'
 
module Switchboard::MessageHandlers::Outgoing
    class TwilioOrEmailOutgoingMessageHandler < Switchboard::MessageHandlers::OutgoingMessageHandler
        def handle_messages!()
            sender = Twilio::TwilioSender.new()
            ## these should come from an array of output connectors (tuple of state & conditions)
            output_state_name = 'sent'
            outgoing_error_state_name = 'error_outgoing'

            output_state_conditions = {}
            outgoing_state = MessageState.find_by_name(output_state_name)
            error_state = MessageState.find_by_name(outgoing_error_state_name)

            outgoing_states = [ outgoing_state ]

            process_count = 0

            ## TODO: change to outgoing_states.each |state,conditions| do 
            messages_to_handle.each do |message|
              ## messages go out slowly, so we will fork a new process for each
              ## message.  We send them out in batches of 30 until we test what
              ## limit is reasonable.

              ## turned off forking because of mysql connection
              #begin
              #  fork {
                  puts "handling outgoing message."
                  if (message.to == 'Web') 
                    puts "WARNING: incorrect messages are being generated to Web"
                  else
                    if ( message.respond_to? :carrier) 
                      puts "emailing message"
                      send_email  message.to, :body => message.body, :from => message.from
                    else 
                      puts "texting response"
                      sender.send_sms( message.to, message.body )
                    end
                  end
              #  }
                outgoing_state.messages.push(message) 
                outgoing_state.save
                rescue
                  error_state.messages.push(message)
                  error_state.save                  
                end
                process_count += 1
               if process_count == 30:
                  ## wait for all child processes to finish
                  Process.waitall ## also important so there are no zombie processes
                  process_count = 0
                end
            end
        end


 
def send_email(to,opts={})
  opts[:server]      ||= 'localhost'
  opts[:from]        ||= ''
  opts[:from_alias]  ||= 'Switchboard'
  opts[:subject]     ||= ""
  opts[:body]        ||= ""
 
  msg = <<END_OF_MESSAGE
From: #{opts[:from_alias]} <#{opts[:from]}>
To: <#{to}>
Subject: #{opts[:subject]}
 
#{opts[:body]}
END_OF_MESSAGE
 
  Net::SMTP.start(opts[:server]) do |smtp|
    smtp.send_message msg, opts[:from], to
  end
end

    end
end



