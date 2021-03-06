require 'test_helper'

class TwilioMessageFlowTest < ActionDispatch::IntegrationTest

  setup do
    @list = lists(:one)
    @from = @list.admin_phone_numbers.first.number
    @number = incoming_phone_numbers(:one)
    @to = @number.phone_number
    @twilio_params = {'Body' => 'Message flow test', 'From' => @from, 'To' => @to}
    @outgoing_count = @list.list_memberships.size
    $redis.flushdb
    Resque.reset!
  end

  test 'incoming twilio through outgoing twilio' do
    post '/messages/twilio/create', @twilio_params
    assert_equal 1, Resque.queue(:incoming).length

    Resque.run!

    assert_equal @outgoing_count, Resque.queue(:outgoing).length
    assert_equal @list.current_month_sms, 1

    TwilioClient.expects(:send_sms).times(@outgoing_count)

    Resque.run!

    # This bit is a little inside baseball, but:

    # List sms count is set, outgoing count + incoming
    assert_equal @list.current_month_sms.to_i, @outgoing_count + 1

    # Message outgoing count is set
    message = Message.where(body: @twilio_params['Body']).first
    assert message
    assert message.sent?
    assert_equal message.outgoing_count.to_i, @outgoing_count, "Message should be marked with #{@outgoing_count} messages, instead says #{message.outgoing_count.to_i}"
  end

end
