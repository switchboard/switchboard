require 'test_helper'

class Messages::TwilioControllerTest < ActionController::TestCase

  context 'receiving a message from Twilio' do
    should 'create a new message' do
      assert_difference 'TwilioMessage.count', 1 do
        post :create, message_params
      end
    end

    should 'set params on new message and queue it' do
      post :create, message_params

      twilio_message = assigns(:message)
      assert twilio_message.body == message_params['Body']
      assert twilio_message.from == message_params['From']
      assert twilio_message.to == message_params['To']
      assert twilio_message.incoming?
    end

    should 'not render a layout' do
      post :create, message_params
      assert response.body == 'OK'
    end
  end


  def message_params
    {'Body' => 'This is a sms body', 'From' => phone_numbers(:one).number, to: lists(:one).incoming_number}
  end
end