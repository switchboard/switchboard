module Switchboard
    class MessageHandler
        ## state to handle messages from
        attr_accessor :state_name, :message_conditions

        ## I think it'd be good if the handler had a set of states it was allowed
        ## to send messages to, and confirmed it was sending them to an allowed state.
        attr_accessor :output_states


        ## This should be extended to have multiple input and output states 
        ## with both input and output states having conditions

        ## A MessageHandler instance handles messages in a particular state,
        ## the name of which is stored in @state.

        ## A MessageHandler can choose to only handle some messages in a 
        ## particular state, and can store conditions to be passed to the
        ## find() method to use to filter messages

        ## override this function in subclasses
        def handle_messages!()
            messages_to_handle.each do |message| 
                puts "abstract message handler called; doing nothing to message " + message.id.to_s
            end 
        end 

        ## messages = MessageState.find_by_name(@state).messages.find(:all,conditions => @conditions)
        def initialize(state_name, message_conditions ) 
            @state_name = state_name
            @message_conditions = message_conditions 
        end 

        ## i was thinking this could be a test run method that reports what it *would* do but maybe not necessary
        def handle_messages()
            ##
        end 

        private
        def messages_to_handle
            messages = input_state.messages.find(:all, :conditions =>  @message_conditions  )
            return messages
        end 

        ## there should be multiple input states
        def input_state
            return MessageState.find_by_name(@state_name)
        end
     
    end
end
