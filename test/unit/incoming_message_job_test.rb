require 'test_helper'

class IncomingMessageJobTest < ActiveSupport::TestCase

  setup do
    @list = lists(:one)
    @twilio_number = incoming_phone_numbers(:one)
  end

  test 'it tells the message to process' do
    @message = FactoryGirl.create(:message, to: @twilio_number.phone_number, body: 'mumble mumble')
    Message.any_instance.expects(:process)

    IncomingMessageJob.perform(@message.id)
  end

  test 'it does not process already-processed messages' do
    @message = FactoryGirl.create(:message, to: @twilio_number.phone_number, body: 'mumble mumble')
    @message.update_column(:aasm_state, 'handled')
    Message.any_instance.expects(:process).never

    assert_raise(ActiveRecord::RecordNotFound) do
      IncomingMessageJob.perform(@message.id)
    end
  end

  test 'it does not process messages where list cannot be determined' do
    @message = FactoryGirl.create(:message, to: '7777777', body: 'mumble mumble')
    Message.any_instance.expects(:process).never
    IncomingMessageJob.perform(@message.id)
  end

end
