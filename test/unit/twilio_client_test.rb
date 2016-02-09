require 'test_helper'

class TwilioClientTest < ActiveSupport::TestCase
  setup do
    @to = '2155551212'
    @from = '2151001000'
    @body = 'Test this SMS'
    # AKA stub_chain
    TwilioClient.stubs(twilio_client: stub(account: stub(messages: stub())))
  end

  test 'adds +1 onto numbers and sends sms' do
    TwilioClient.twilio_client.account.messages.expects(:create).with(from: "+1#{@from}", to: "+1#{@to}", body: @body)
    TwilioClient.send_sms(@to, @body, @from)
  end

  test 'does not add +1 when numbers already have it' do
    TwilioClient.twilio_client.account.messages.expects(:create).with(from: "+1#{@from}", to: "+1#{@to}", body: @body)
    TwilioClient.send_sms("+1#{@to}", @body, "+1#{@from}")
  end

  # incoming_phone_numbers fetching tested in IncomingPhoneNumbersTest
end