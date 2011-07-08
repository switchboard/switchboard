require 'switchboard/message_handlers/incoming_message_handler.rb'
require 'twilio/twilio_sender'

module Switchboard::MessageHandlers::Incoming
  class DemoListMessageHandler < Switchboard::MessageHandlers::IncomingMessageHandler

    ## Determine which list a message has been sent to.
    ## Methods:
    ## 1) The recipient phone number has a single list assigned to it.
    ## 2) Email messages have an assigned list (each address specifies a list)
    ## 3) Message from the web interface have the list set as message.to  
    ## 4) Messages to a keyword list are assumed to have the first token set to the
    ##    list name
    ##  
    ## For the future: ?TODO: create model for incoming numbers/gateways/channels/etc.
    ## -- Incoming numbers should have their own model
    ## -- Give numbers that handle messages by keyword a default list

    def determine_list ( message )
        list = nil
        if ( List.find_by_incoming_number(message.to) != nil)
          ## Non-keyword list (assigned phone number)
          list = List.find_by_incoming_number(message.to)
        elsif ( message.respond_to? :carrier )
          ## Email message for a list
          list_name = message.default_list 
          list = List.find_by_name(message.default_list)
        elsif ( message.from_web? )
          ## Web message
          list = List.find_by_id(message.to)
        else
          ## Keyword list
          list_name = message.tokens.shift
          list_name.upcase!
          list = List.find_by_name(list_name)
         
        end

        return list
    end

    ## Main method for handling incoming messages.
    ## Determine which list the message is headed for, determine action, handle action.
    def handle_messages!()
      puts ("Handling incoming messages")
      default_outgoing_number = "2153466997"

      ##?REVIEW: could have multiple outgoing states
      handled_state = MessageState.find_by_name('handled')
      error_state = MessageState.find_by_name("error_incoming")

      messages_to_handle.each do |message|
        begin
          puts ("Handling incoming messages -- individual message")
          message.tokens = message.body.split(/ /)
          
          list = determine_list(message) 
          if ( list == nil ) 
            puts("couldn't determine list")
            Rails.logger.warn("couldn't determine list")
            error_state.messages.push(message)
            error_state.save
            next
          end 

          number_string = message.sender_number
          puts "Message is from number: " + number_string

          num = PhoneNumber.find_or_create_by_number( number_string ) 
          num.save

          ##?REVIEW: handle this more elegantly 
          ##If the message comes via email, save the carrier address.
          if (message.respond_to? :carrier)  
           num.provider_email = message.carrier 
          end

          if ( message.tokens.count > 0 ) 
            first_token = message.tokens[0]
          else
            Rails.logger.warn("empty message")
            puts("empty message")
            error_state.messages.push(message)
            error_state.save
            next
          end
        
          if ( first_token =~ /^join$/i )  ## join action
             list.handle_join_message(message, tokens, num)
             next 
          elsif ( first_token =~ /^leave$/i or first_token =~ /^quit$/i )  ## quit action
            ##?TODO: move to list model 
            Rails.logger.info("Received list quit message")
            list.create_outgoing_message( num, "You have been removed from the " + list_name + " list, as you requested." )
            list.remove_phone_number(num)
            list.save
           else ## send action (send a message to a list)
             Rails.logger.info("List received a message: " + list.name )
             list.handle_send_action(message, num)
           end

           handled_state.messages.push(message)
           handled_state.save
        rescue StandardError => e
          puts("exception while processing message")
          puts("error was: " + e.inspect )
          puts("error backtrace: " + e.backtrace.inspect )
          puts("error was: " + e.inspect )
          puts("e: " + e.to_s )

          Rails.logger.warn("exception while processing message")
          error_state.messages.push(message)
          error_state.save
        end
      end  ## message loop -- handled a message
    end
  end
end
