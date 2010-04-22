class ReceiveSmsController < ApplicationController
    skip_before_filter :verify_authenticity_token
    def index
    end 

    def twilio
      if request.post?
        @message = TwilioMessage.create_from_params(params)
        queue_message
      end
    end

  protected

  def queue_message
    incoming = MessageState.find_or_create_by_name("incoming")
    incoming.messages << @message
  end

end
