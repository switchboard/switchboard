class Messages::EmailController < MessagesController
  layout 'application'

  def create
    @message = EmailMessage.create_from_params(params)
    super
    render text: 'OK'
  end

  def view
    @messages = EmailMessage.scoped
  end

end
