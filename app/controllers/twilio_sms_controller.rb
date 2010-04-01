class TwilioSmsController < ApplicationController
    skip_before_filter :verify_authenticity_token
    def index
        body = params['Body']
        from = params['From']
        to = params['To']
        sms_sid = params['SmsSid']
        account_sid = params['AccountSid']

        Message.create(:from => from, :to => to, :body => body, :origin => 'twilio', :origin_id => 'sms_sid')  
    end 
end
