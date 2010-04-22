#!/usr/bin/env ruby

require 'twilio/twiliolib'

## This object can send SMS messages using Twilio as a gateway.
## josh -- 4/22/2010

module Twilio

    # Twilio REST API version
    API_VERSION = '2008-08-01'

    # Twilio AccountSid and AuthToken
    ACCOUNT_SID = 'AC8320a2e64a184dd450a41a8533020e81'
    ACCOUNT_TOKEN = '42dac91b4dba8a556f7049bf022809e2'

    # Sender phone number needs to be a number previously validated with Twilio
    CALLER_ID = "215-346-6997"
    ## my google voice account = "267-702-4687"
    ## BODY = 'an even newer a new message'

    class TwilioSender
        def send_sms( recipient_phone_number, message, sender_phone_number=CALLER_ID) 
            # Create a Twilio REST account object using your Twilio account ID and token
            
            account = Twilio::RestAccount.new(ACCOUNT_SID, ACCOUNT_TOKEN)

            d = {
                'To' => recipient_phone_number,
                'From' => CALLER_ID,
                'Body' => message
            }
            resp = account.request("/#{API_VERSION}/Accounts/#{ACCOUNT_SID}/SMS/Messages",
            'POST', d)
            resp.error! unless resp.kind_of? Net::HTTPSuccess
            puts "code: %s\nbody: %s" % [resp.code, resp.body]
        end
    end
end
