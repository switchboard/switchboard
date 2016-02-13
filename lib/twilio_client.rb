class TwilioClient

  def self.send_sms(recipient_phone_number, message, sender_phone_number)
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

  def self.delete_incoming_phone_number(sid)
    number = twilio_client.account.incoming_phone_numbers.get(sid)
    begin
      number.delete
    rescue => e
      #
    end
  end

  def self.twilio_client
    @@client ||= Twilio::REST::Client.new(Settings.twilio.sid, Settings.twilio.token)
  end

end