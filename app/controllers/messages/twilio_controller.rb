class Messages::TwilioController < MessagesController 

    def create 
      @message = TwilioMessage.create_from_params(params)
      super
    end

    def view
      @messages = TwilioMessage.find(:all)
    end
end
