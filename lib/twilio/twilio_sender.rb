#!/usr/bin/env ruby

require 'rubygems' # not necessary with ruby 1.9 but included for completeness
require 'twilio-ruby'

## This object can send SMS messages using Twilio as a gateway.
## josh -- 4/22/2010

module Twilio

    # Sender phone number needs to be a number previously validated with Twilio
    CALLER_ID = "+12153466997"

    class TwilioSender
        def send_sms( recipient_phone_number, message, sender_phone_number=CALLER_ID)

        if ! sender_phone_number.start_with?("+1")
            sender_phone_number = "+1" + sender_phone_number
        end
        if ! recipient_phone_number.start_with?("+1")
            recipient_phone_number = "+1" +  recipient_phone_number
        end
        Rails.logger.debug("Sender is: " + sender_phone_number)
        Rails.logger.debug("Recipient id is: " + recipient_phone_number)
        Rails.logger.debug("Message: " + message)

            # Create a Twilio REST account object using your Twilio account ID and token
        # set up a client to talk to the Twilio REST API
	    @client = Twilio::REST::Client.new(Settings.twilio.sid, Settings.twilio.token)

    	@client.account.sms.messages.create(
    	  :from => sender_phone_number,
    	  :to => recipient_phone_number,
    	 :body => message
    	)
        end
    end
end
