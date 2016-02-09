class TwilioClient
  # Sender phone number needs to be a number previously validated with Twilio
  CALLER_ID = "+12153466997"

  def self.send_sms(recipient_phone_number, message, sender_phone_number = CALLER_ID)
    unless sender_phone_number.start_with?("+1")
      sender_phone_number = "+1#{sender_phone_number}"
    end
    unless recipient_phone_number.start_with?("+1")
      recipient_phone_number = "+1#{recipient_phone_number}"
    end

    twilio_client.account.messages.create(
      from: sender_phone_number,
      to: recipient_phone_number,
      body: message
    )
  end

  def self.incoming_phone_numbers
    twilio_client.account.incoming_phone_numbers.list
  end

  def self.twilio_client
    @@client ||= Twilio::REST::Client.new(Settings.twilio.sid, Settings.twilio.token)
  end

end