class SendSmsController < ApplicationController
    skip_before_filter :verify_authenticity_token
    def index
    end 

    def twilio
    end

end
