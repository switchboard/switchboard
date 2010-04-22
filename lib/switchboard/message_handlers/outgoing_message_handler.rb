require 'switchboard/message_handler.rb'

module Switchboard
    module MessageHandlers
        class OutgoingMessageHandler < Switchboard::MessageHandler
            def initialize(message_conditions={}) 
                super('outgoing', message_conditions)
            end
        end
    end
end
