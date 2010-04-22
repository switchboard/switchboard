require 'switchboard/message_handler.rb'

package Switchboard::MessageHandlers
    class OutgoingMessageHandler < MessageHandler
        def initialize(message_conditions={}) 
            super('outgoing', message_conditions)
        end
    end
end
