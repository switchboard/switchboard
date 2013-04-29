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
      	puts("determining list.")
        puts("message.to: " + message.to)
        to_number = message.to.to_s.gsub(/[^0-9]/, '')
        to_number = to_number[-10..-1] || to_number
        if list = List.find_by_incoming_number(to_number)
          ## Non-keyword list (assigned phone number)
        elsif message.respond_to? :carrier
          ## Email message for a list
          list_name = message.default_list
          list = List.find_by_name(message.default_list)
        elsif message.from_web?
          ## Web message
          list = List.find_by_id(message.to)
        else
          ## Keyword list
          list_name = message.tokens.shift
          list_name.upcase!
          list = List.find_by_name(list_name)
        end

        list
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

          number_string = message.sender_number
          number_string.sub!("+1", "")
          puts "Message is from number: " + number_string

          num = PhoneNumber.find_or_create_by_number( number_string )
          num.save

          survey_state = SurveyState.where(active: true, phone_number_id: 1).first

          if ( survey_state != nil )
            puts("handle survey response.")
            survey_state.handle_message(num, message.body)
            handled_state.messages.push(message)
            handled_state.save
            next
          end

          list = determine_list(message)
          if ( list == nil )
            puts("couldn't determine list")
            Rails.logger.warn("couldn't determine list")
            error_state.messages.push(message)
            error_state.save
            next
          end

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
             list.handle_join_message(message, num)
          elsif ( first_token =~ /^leave$/i or first_token =~ /^quit$/i )  ## quit action
            ##?TODO: move to list model
            Rails.logger.info("Received list quit message")
            list.create_outgoing_message( num, "You have been removed from the " + list.name + " list, as you requested." )
            list.remove_phone_number(num)
            list.save
           else ## send action (send a message to a list)
             Rails.logger.info("List received a message: " + list.name )
             list.handle_send_action(message, num)
           end

           handled_state.messages.push(message)
           handled_state.save
        rescue StandardError => e
          Airbrake.notify_or_ignore(e)

          Rails.logger.warn("exception while processing message")
          Rails.logger.warn("error was: " + e.inspect )
          Rails.logger.warn("error backtrace: " + e.backtrace.inspect )
          error_state.messages.push(message)
          error_state.save
        end
      end  ## message loop -- handled a message
    end
  end
end
