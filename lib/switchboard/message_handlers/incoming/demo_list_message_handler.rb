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
      default_outgoing_number = "2153466997"

      ##?REVIEW: could have multiple outgoing states
      handled_state = MessageState.find_by_name('handled')
      messages_to_handle.each do |message|
        message.tokens = message.body.split(/ /)
        
        list = determine_list(message) 
        if ( list == nil ) 
          Rails.logger.warn("couldn't determine list")
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

        if ( message.tokens.count > 1 ) 
          first_token = message.tokens[0]
        else
          Rails.logger.warn("empty message")
          next
        end
    
        if ( first_token =~ /^join$/i )  ## join action
          handle_join_message(message, list_name, tokens, num)
          next 
        elsif ( first_token =~ /^leave$/i or first_token =~ /^quit$/i )  ## quit action
          Rails.logger.info("Received list quit message")
          list = List.find_by_name(list_name)
          create_outgoing_message( num, message.to, "You have been removed from the " + list_name + " list, as you requested." )
          list.remove_phone_number(num)
          list.save
          handled_state.messages.push(message)
          next
       else ## send action (send a message to a list)
        Rails.logger.info("List received a message: " + list.name )
        list.handle_send_action(message, num)
        handled_state.messages.push(message)
      end
      handled_state.save
    end  ## message loop -- handled a message
  end

      def create_outgoing_message(num, from, body)
          if ( num.provider_email != '' and num.provider_email != nil  )
            puts "sending email message"
            message = EmailMessage.new
            message.to = num.number + "@" + num.provider_email
            message.from = from
          else
            puts "sending twilio message to: " + num.number
            message = TwilioMessage.new
            message.to = num.number
          end

          message.body = body

          message_state = MessageState.find_by_name("outgoing")
          message_state.messages.push(message)
          message_state.save! 
      end

      def handle_join_message(message, list, tokens, num)
        puts "join message found"

        if list.has_number?(num) 
          create_outgoing_message( num, message.to, "It seems like you are trying to join the list '" + list_name + "', but you are already a member.")
        else
          if (list.open_membership)
            message.list = list
            if (num.user == nil)
              puts "adding user for num: " + num.number
              num.user = User.create(:password => 'abcdef981', :password_confirmation => 'abcdef981')
              num.save
              num.user.save
            end

            list.add_phone_number(num)

            message.sender = num.user
            message.save

          else ## not list.open_membership
            create_outgoing_message( num, message.to, "I'm sorry, but this list is configured as a private list and only the administrator can add new members.")
          end
        end
        handled_state.messages.push(message)
      end

    end
end
