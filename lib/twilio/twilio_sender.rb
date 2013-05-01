require 'twilio-ruby'

module Twilio
  # Sender phone number needs to be a number previously validated with Twilio
  CALLER_ID = "+12153466997"

  class TwilioSender

    def self.send_sms(recipient_phone_number, message, sender_phone_number = CALLER_ID)

      unless sender_phone_number.start_with?("+1")
        sender_phone_number = "+1#{sender_phone_number}"
      end

      unless recipient_phone_number.start_with?("+1")
        recipient_phone_number = "+1#{recipient_phone_number}"
      end

      twilio_client.account.sms.messages.create(
        from: sender_phone_number,
        to: recipient_phone_number,
        body: message
        )
    end

    def self.twilio_client
      @@client ||= Twilio::REST::Client.new(Settings.twilio.sid, Settings.twilio.token)
    end

  end
end
