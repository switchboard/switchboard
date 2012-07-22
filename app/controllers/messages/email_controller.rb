class Messages::EmailController < MessagesController

    def create
      @message = EmailMessage.create_from_params(params)
      super
    end

    def view
      @messages = EmailMessage.scoped
    end

end
