require 'test_helper'

class MessageTest < ActiveSupport::TestCase

  context 'incoming message' do
    setup do
      @list = lists(:one)
      @message = FactoryGirl.create(:message, to: @list.incoming_number, body: 'mumble mumble')
    end

    should 'parse the list correctly from the number' do
      assert @message.list_id == @list.id
    end

    should 'mark processing if ready' do
      @message.mark_processing!
      assert @message.aasm_state == 'processing'
    end

    should 'enqueue resque job' do
      Resque.expects(:enqueue)
      @message = FactoryGirl.create(:message, to: @list.incoming_number, body: 'mumble mumble')
    end

    should 'mark as an error if list cannot calculate list' do
      @message = FactoryGirl.create(:message, to: '9990001234', body: 'JOIN mumble mumble')
      @message.save
      @message.mark_processing!

      assert @message.aasm_state == 'failure'
    end

    should 'mark as an error if body is empty' do
      @message = FactoryGirl.create(:message, to: @list.incoming_number, body: '')
      @message.save
      @message.mark_processing!

      assert @message.aasm_state == 'failure'
    end
  end

  # There's no UI for them ATM, but this is how keyword lists _would_ work
  context 'incoming keyword-list message' do
    setup do
      @list = lists(:two)
      @message = FactoryGirl.create(:message, to: '555-555-5555', body: "#{@list.name} mumble mumble")
    end

    should 'parse the list correctly from the number' do
      assert @message.list_id == @list.id
    end
  end

  context 'incoming join message' do
    setup do
      @list = lists(:one)
      @message = FactoryGirl.create(:message, to: @list.incoming_number, body: 'JOIN mumble mumble')
      @message.mark_processing!
    end

    should 'tell list to send join message' do
      List.any_instance.expects(:handle_join_message).with(@message).returns(true)
      @message.process

      assert @message.aasm_state == 'handled'
    end
  end

  context 'incoming leave message' do
    setup do
      @list = lists(:one)
      @message = FactoryGirl.create(:message, to: @list.incoming_number, body: 'LEAVE mumble mumble')
      @message.mark_processing!
    end

    should 'tell list to send leave message' do
      List.any_instance.expects(:handle_leave_message).with(@message).returns(true)
      @message.process

      assert @message.aasm_state == 'handled'
    end
  end

  context 'incoming regular message' do
    setup do
      @list = lists(:one)
      @message = FactoryGirl.create(:message, to: @list.incoming_number, body: 'mumble mumble mumble')
      @message.mark_processing!
    end

    should 'tell list to handle message' do
      List.any_instance.expects(:handle_send_action).with(@message).returns(true)
      @message.process

      assert @message.aasm_state == 'in_send_queue'
    end
  end
  
end