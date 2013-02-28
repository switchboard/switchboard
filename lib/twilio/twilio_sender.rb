#!/usr/bin/env ruby


require 'rubygems' # not necessary with ruby 1.9 but included for completeness
require 'twilio-ruby'


## This object can send SMS messages using Twilio as a gateway.
## josh -- 4/22/2010

module Twilio

    # Twilio REST API version
    API_VERSION = '2008-08-01'

    # Twilio AccountSid and AuthToken
    ACCOUNT_SID = 'AC8320a2e64a184dd450a41a8533020e81'
    ACCOUNT_TOKEN = '42dac91b4dba8a556f7049bf022809e2'

    # Sender phone number needs to be a number previously validated with Twilio
    CALLER_ID = "+12153466997"
    ## my google voice account = "267-702-4687"
    ## BODY = 'an even newer a new message'

    class TwilioSender
        def send_sms( recipient_phone_number, message, sender_phone_number=CALLER_ID) 

        if ! sender_phone_number.start_with?("+1")
            sender_phone_number = "+1" + sender_phone_number
        end      
        if ! recipient_phone_number.start_with?("+1")
            recipient_phone_number = "+1" +  recipient_phone_number 
        end
        puts("caller id is: " + sender_phone_number)
        puts("recipient id is: " + recipient_phone_number)
        puts("message is: " + message)

            # Create a Twilio REST account object using your Twilio account ID and token
        # set up a client to talk to the Twilio REST API
	    @client = Twilio::REST::Client.new ACCOUNT_SID, ACCOUNT_TOKEN

    	@client.account.sms.messages.create(
    	  :from => sender_phone_number,
    	  :to => recipient_phone_number,
    	 :body => message
    	)
        end
    end
end
