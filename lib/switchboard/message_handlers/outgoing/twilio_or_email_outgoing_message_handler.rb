require 'switchboard/message_handlers/outgoing_message_handler.rb'
require 'twilio/twilio_sender'
require 'net/smtp'
 
module Switchboard::MessageHandlers::Outgoing
  class TwilioOrEmailOutgoingMessageHandler < Switchboard::MessageHandlers::OutgoingMessageHandler
    def handle_messages!()
      puts(" ** handling outgoing messages.")
      sender = Twilio::TwilioSender.new()
      ## these should come from an array of output connectors (tuple of state & conditions)
      sent_state_name = 'sent'
      outgoing_error_state_name = 'error_outgoing'

      output_state_conditions = {}
      sent_state = MessageState.find_by_name(sent_state_name)
      error_state = MessageState.find_by_name(outgoing_error_state_name)

      ##outgoing_states = [ outgoing_state ]

      ## NOTE: in generic model, change to outgoing_states.each |state,conditions| do 

      process_count = 0

      messages_to_handle.each do |message|
        ## messages go out slowly, so we will fork a new process for each
        ## message.  We send them out in batches of 30 until we test what
        ## limit is reasonable.

        ## turned off forking because of mysql connection
        #threads = []
        #threads << Thread.new(msg) { |message| 
        begin
          puts "handling outgoing message."
          if (message.to == 'Web') 
            puts "WARNING: incorrect messages are being generated to Web"
          else
            if ( message.respond_to? :carrier) 
              puts "emailing message"
              send_email  message.to, :body => message.body, :from => message.from
            else 
              if (message.from == nil || message.from == '') 
                #TODO: system wide settings 
                puts("sending from sender: system wide sender")
                sender.send_sms( message.to, message.body)
              else
                puts("sending from sender: " + message.from )
                sender.send_sms( message.to, message.body, message.from)
              end
            end
          end
          message.message_state = sent_state 
          message.save
        rescue Exception => e
          puts("outgoing messages -- failure")
          puts("error was: " + e.inspect )
          puts("error backtrace: " + e.backtrace.inspect )
          puts("error was: " + e.inspect )
          puts("e: " + e.to_s )
          error_state.messages.push(message)
          error_state.save                  
        end
        #}
        #threads.each { |aThread| aThread.join }
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



