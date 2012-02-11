#!/usr/bin/env ruby


require 'rubygems' # not necessary with ruby 1.9 but included for completeness
require 'twilio-ruby'


## This object can send SMS messages using Twilio as a gateway.
## josh -- 4/22/2010

module Twilio
	# put your own credentials here
    account_sid = 'AC81adcdb46ea4cf1591c5a38b7a8880b2'
    auth_token = 'ff3078a5e4500295215eddddd636f64c'


    # Twilio REST API version
    API_VERSION = '2008-08-01'

    # Twilio AccountSid and AuthToken
    ACCOUNT_SID = 'AC81adcdb46ea4cf1591c5a38b7a8880b2'
    ACCOUNT_TOKEN = 'ff3078a5e4500295215eddddd636f64c'

    # Sender phone number needs to be a number previously validated with Twilio
    CALLER_ID = "+12674158777"
    ## my google voice account = "267-702-4687"
    ## BODY = 'an even newer a new message'

    class TwilioSender
        def send_sms( recipient_phone_number, message, sender_phone_number=CALLER_ID) 

        if ! sender_phone_number.start_with?("+1"):
            sender_phone_number = "+1" + sender_phone_number
        end      
        if ! recipient_phone_number.start_with?("+1"):
            recipient_phone_number = "+1" +  recipient_phone_number 
        end
        puts("caller id is: " + sender_phone_number)
        puts("recipient id is: " + recipient_phone_number)
        puts("message is: " + message)
        account_sid = 'AC81adcdb46ea4cf1591c5a38b7a8880b2'
        auth_token = 'ff3078a5e4500295215eddddd636f64c'

            # Create a Twilio REST account object using your Twilio account ID and token
        # set up a client to talk to the Twilio REST API
	    @client = Twilio::REST::Client.new account_sid, auth_token

    	@client.account.sms.messages.create(
    	  :from => sender_phone_number,
    	  :to => recipient_phone_number,
    	 :body => message
    	)
        end
    end
end
