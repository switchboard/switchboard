class TwilioSmsController < ApplicationController
    skip_before_filter :verify_authenticity_token
    def index
        body = params['Body']
        from = params['From']
        to = params['To']
        sms_sid = params['SmsSid']
        account_sid = params['AccountSid']

        message = Message.create(:from => from, :to => to, :body => body, :origin => 'twilio', :origin_id => 'sms_sid')  
        incoming = MessageState.find_or_create_by_name("incoming")
        incoming.messages << message
    end 
end
