class Messages::TwilioController < MessagesController 
  layout 'application'

  def create
    @message = TwilioMessage.create_from_params(params)
    super
    render text: 'OK'
  end

  def view
    @messages = TwilioMessage.scoped
  end
end
