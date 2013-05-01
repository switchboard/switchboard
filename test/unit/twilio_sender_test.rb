require 'test_helper'

class TwilioSenderTest < ActiveSupport::TestCase
  setup do
    @to = '2155551212'
    @from = '2151001000'
    @body = 'Test this SMS'
    # AKA stub_chain
    TwilioSender.stubs(twilio_client: stub(account: stub(sms: stub(messages: stub()))))
  end

  test 'adds +1 onto numbers and sends sms' do
    TwilioSender.twilio_client.account.sms.messages.expects(:create).with(from: "+1#{@from}", to: "+1#{@to}", body: @body)
    TwilioSender.send_sms(@to, @body, @from)
  end

  test 'does not add +1 when numbers already have it' do
    TwilioSender.twilio_client.account.sms.messages.expects(:create).with(from: "+1#{@from}", to: "+1#{@to}", body: @body)
    TwilioSender.send_sms("+1#{@to}", @body, "+1#{@from}")
  end

end