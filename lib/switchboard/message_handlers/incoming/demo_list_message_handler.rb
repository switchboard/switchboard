require 'switchboard/message_handlers/incoming_message_handler.rb'
require 'twilio/twilio_sender'

module Switchboard::MessageHandlers::Incoming
  class DemoListMessageHandler < Switchboard::MessageHandlers::IncomingMessageHandler
    def handle_messages!()
      ## should be  outgoing_states.each |state,conditions| do 
      handled_state = MessageState.find_by_name('handled')
      messages_to_handle.each do |message|
      tokens = message.body.split(/ /)
      puts tokens.to_s 

      message_sender = ''
      if ( message.respond_to? :carrier )
        list_name = message.default_list 
        puts "received email message for list " + list_name
        message_sender = message.to
      elsif ( message.from_web? )
        puts "received web message"
        list_id = message.to
        list_name = List.find_by_id(list_id).name
        puts " -- web message for list " + list_name
        message_sender = '2153466997'
      else
        list_name = tokens.shift
        list_name.upcase!
        puts "received text message for list: " + list_name
        message_sender = '2153466997'
      end


      if (message.respond_to? :carrier ) 
        number_string = message.number
      else
        number_string = message.from
      end  

      puts "Message is from number: " + number_string

      num = PhoneNumber.find_or_create_by_number( number_string ) 

      if (message.respond_to? :carrier)  
        num.provider_email = message.carrier 
      end  

      if (tokens.length == 0 or ( tokens.length == 1 and tokens[0] =~ /join/i ) )
        puts "join message found"
        list = List.find_or_create_by_name(list_name)

        if list.has_number?(num) 
          create_outgoing_message( num, message.to, "It seems like you are trying to join the list '" + list_name + "', but you are already a member.")
        else
          if (list.open_membership)
            message.list = list
            if (num.user == nil)
              puts "adding user for num: " + num.number
              num.user = User.create(:password => 'abcdef981', :password_confirmation => 'abcdef981')
              num.user.first_name = 'Unknown'
              num.save
              num.user.save
            end
            list.add_phone_number(num)
            message.sender = num.user
            message.save
            welcome_message = "You have joined the text message list called '" + list_name + "'!"
            if list.use_welcome_message?:
              puts "this list uses the welcome message"
              welcome_message = list.custom_welcome_message
            end

            create_outgoing_message( num, message.to, welcome_message ) 
          else ## not list.open_membership
            create_outgoing_message( num, message.to, "I'm sorry, but this list is configured as a private list and only the administrator can add new members.")
          end
        end
        handled_state.messages.push(message)
      end
          
      if (tokens.length > 1) 
        if List.exists?({:name => list_name}) 
          list = List.find_by_name(list_name)
          message.list = list
          message.sender = num.user 
          message.save
          if (message.from_web? or list.all_users_can_send_messages?)
            list.phone_numbers.each do |phone_number|
              body = '[' + list_name + '] ' + tokens.join(' ')
              puts "sending message: " + body + ", to: " + phone_number.number
              list.create_outgoing_message(phone_number, body)
            end
          end
          handled_state.messages.push(message)
        else 
          create_outgoing_message(num, message_sender, "I'm sorry but I'm not sure what list you're trying to reach!" ) unless message.from_web?
          handled_state.messages.push(message)
        end
      end 
      handled_state.save
    end
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
    end
end
