require 'test_helper'

class OutgoingMessageTest < ActiveSupport::TestCase
  context "with an email address as 'to'" do
    setup do
      @list_id = 123
      @from = phone_numbers(:one).number
      @to = '2155551212@example.com'
      @body = 'This is an email message'
    end

    should 'send an email' do
      OutgoingMessage.expects(:send_email).with(@to, {body: @body, from: @from})
      OutgoingMessage.perform(@list_id, @to, @from, @body)
    end

  end

  context 'sending sms' do
    setup do
      @list_id = 123
      @from = phone_numbers(:one).number
      @to = '2155551212'
      @body = 'This is a SMS'
    end

    should 'send an sms with TwilioSender' do
      TwilioSender.expects(:send_sms).with(@to, @body, @from)
      OutgoingMessage.perform(@list_id, @to, @from, @body)
    end

    should 'increment list outgoing count but not message count' do
      TwilioSender.stubs(:send_sms)
      List.expects(:increment_outgoing_count).with(@list_id)
      Message.expects(:increment_outgoing_count).never

      OutgoingMessage.perform(@list_id, @to, @from, @body)
    end

    should 'increment message outgoing count when passed a message id' do
      @message_id = '555'
      TwilioSender.stubs(:send_sms)
      List.expects(:increment_outgoing_count).with(@list_id)
      Message.expects(:increment_outgoing_count).with(@message_id)

      OutgoingMessage.perform(@list_id, @to, @from, @body, @message_id)
    end

  end
end
