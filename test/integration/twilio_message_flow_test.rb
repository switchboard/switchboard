require 'test_helper'

class TwilioMessageFlowTest < ActionDispatch::IntegrationTest

  setup do
    @list = lists(:one)
    @from = @list.admin_phone_numbers.first.number
    @to = @list.incoming_number
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

    TwilioSender.expects(:send_sms).times(@outgoing_count)

    Resque.run!

    # This bit is a little inside baseball, but:

    # List outgoing count is set
    assert_equal @list.outgoing_count.to_i, @outgoing_count

    # Message outgoing count is set
    message = Message.where(body: @twilio_params['Body']).first
    assert message
    assert message.sent?
    assert_equal message.outgoing_count.to_i, @outgoing_count, "Message should be marked with #{@outgoing_count} messages, instead says #{message.outgoing_count.to_i}"
  end

end
