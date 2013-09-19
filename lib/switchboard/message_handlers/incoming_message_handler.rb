require 'switchboard/message_handler.rb'

module Switchboard
    module MessageHandlers
        class IncomingMessageHandler < Switchboard::MessageHandler
            def initialize(message_conditions={}) 
                super('incoming', message_conditions)
            end
        end
    end
end
