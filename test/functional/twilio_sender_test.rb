require 'twilio/twilio_sender'

sender = Twilio::TwilioSender.new()
sender.send_sms('2677024687', 'twilio sender test successful') 
