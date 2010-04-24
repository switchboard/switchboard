require 'test_helper'

class ReceiveSmsControllerTest < ActionController::TestCase

  def test_index
    get :index
    assert_respose :success
  end

  def test_twilio_get
    get :twilio
    assert_response :success
  end

  def test_twilio_post
    post :twilio, :Body => 'hi', :From => '9999999999', :To => '1111111111', :SmsSid => 'somesid'
    assert assigns[:message]
  end

end
