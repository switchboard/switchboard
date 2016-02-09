require 'test_helper'

class OutgoingMessageJobTest < ActiveSupport::TestCase
  context "with an email address as 'to'" do
    setup do
      @list_id = 123
      @from = phone_numbers(:one).number
      @to = '2155551212@example.com'
      @body = 'This is an email message'
    end

    should 'send an email' do
      OutgoingMessageJob.expects(:send_email).with(@to, {body: @body, from: @from})
      OutgoingMessageJob.perform(@list_id, @to, @from, @body)
    end

  end

  context 'sending sms' do
    setup do
      @list_id = 123
      @from = phone_numbers(:one).number
      @to = '2155551212'
      @body = 'This is a SMS'
    end

    should 'send an sms with TwilioClient' do
      TwilioClient.expects(:send_sms).with(@to, @body, @from)
      OutgoingMessageJob.perform(@list_id, @to, @from, @body)
    end

    context 'without a message_id' do
      should 'increment list outgoing count but not message count' do
        TwilioClient.stubs(:send_sms)
        List.expects(:increment_sms_count).with(@list_id)
        Message.expects(:increment_outgoing_count).never

        OutgoingMessageJob.perform(@list_id, @to, @from, @body)
      end
    end

    context 'with a message id' do
      setup do
        @message_id = 555
        @message_count = 5
        TwilioClient.stubs(:send_sms)
        List.expects(:increment_sms_count).with(@list_id)
        Message.expects(:increment_outgoing_count).with(@message_id).returns(@message_count)
      end

      should 'increment message outgoing count when passed a message id' do
        OutgoingMessageJob.perform(@list_id, @to, @from, @body, @message_id, @message_count + 10)
      end

      should 'mark message as sent when outgoing count equals expected total count' do
        Message.expects(:find).with(@message_id).returns(stub(:mark_sent!))
        OutgoingMessageJob.perform(@list_id, @to, @from, @body, @message_id, @message_count)
      end
    end

  end
end
