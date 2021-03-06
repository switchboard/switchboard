require 'test_helper'

class MessageTest < ActiveSupport::TestCase

  context 'incoming message' do
    setup do
      @list = lists(:one)
      @number = incoming_phone_numbers(:one)
      @message = FactoryGirl.create(:message, to: @number.phone_number, body: 'mumble mumble')
    end

    should 'parse the list correctly from the number' do
      assert @message.list_id == @list.id
    end

    should 'increment list sms count' do
      message = FactoryGirl.build(:message, to: @number.phone_number, body: 'mumble mumble')
      List.any_instance.expects(:increment_sms_count)
      message.save
    end

    should 'not increment list sms count for web messages' do
      message = FactoryGirl.build(:web_message, list: @list, body: 'mumble mumble')
      List.any_instance.expects(:increment_sms_count).never
      message.save
    end

    should 'mark processing if ready' do
      @message.mark_processing!
      assert @message.aasm_state == 'processing'
    end

    should 'mark as an error if list cannot calculate list' do
      @message = FactoryGirl.create(:message, to: '9990001234', body: 'JOIN mumble mumble')
      @message.save
      @message.mark_processing!

      assert @message.aasm_state == 'failure'
    end

    should 'mark as an error if body is empty' do
      @message = FactoryGirl.create(:message, to: @number.phone_number, body: '')
      @message.save
      @message.mark_processing!

      assert @message.aasm_state == 'failure'
    end

    context 'message ready to be processed' do
      setup do
        @message.mark_processing!
      end

      context 'message can be sent' do
        setup do
          List.any_instance.expects(:can_send_message?).with(@message).returns(true)
        end

        should 'tell list to handle message, mark as in_send_queue' do
          List.any_instance.expects(:handle_send_action).with(@message)
          @message.process
          assert @message.reload.aasm_state == 'in_send_queue', "aasm_state should be in_send_queue, was #{@message.aasm_state}"
        end

        should 'enqueue resque job' do
          Resque.expects(:enqueue).times(@list.phone_numbers.size)
          @message.process
        end
      end

      context 'list requires confirmation' do
        setup do
          List.any_instance.stubs(:can_send_message?).returns(false)
          List.any_instance.stubs(:message_needs_confirmation?).returns(true)
          List.any_instance.stubs(:can_admin_message?).returns(true)
        end

        should 'tell list to send confirmation, mark as needs_confirmation' do
          List.any_instance.expects(:send_confirmation_message).with(@message)
          @message.process
          assert @message.reload.aasm_state == 'needs_confirmation', "aasm_state should be needs_confirmation, was #{@message.aasm_state}"
        end
      end


      context 'message cannot be sent but is administered' do
        setup do
          List.any_instance.stubs(:can_send_message?).returns(false)
          List.any_instance.stubs(:can_admin_message?).returns(true)
        end

        should 'mark as forwarded_to_admin' do
          List.any_instance.expects(:send_admin_message).with(@message)
          @message.process
          assert @message.reload.aasm_state == 'forwarded_to_admin'
        end
      end

      context 'message cannot be sent or administered' do
        setup do
          List.any_instance.stubs(:can_send_message?).returns(false)
          List.any_instance.stubs(:can_admin_message?).returns(false)
        end

        should 'mark as ignored' do
          @message.process
          assert @message.reload.aasm_state == 'ignored'
        end
      end
    end

  end

  # There's no UI for them ATM, but this is how keyword lists _would_ work
  context 'incoming keyword-list message' do
    setup do
      @list = lists(:two)
      @number = incoming_phone_numbers(:two)
      @message = FactoryGirl.create(:message, to: '555-555-5555', body: "#{@list.name} mumble mumble")
    end

    should 'parse the list correctly from the number' do
      assert @message.list_id == @list.id
    end
  end

  context 'incoming confirmation message' do
    setup do
      @list = lists(:one)
      @list.update_column(:require_admin_confirmation, true)
      @number = incoming_phone_numbers(:one)
      @admin_phone = phone_numbers(:one)

      command = I18n.t('list_commands.confirm', locale: :en)
      command = command[0] if command.is_a?(Array)

      @message = FactoryGirl.create(:message, to: @number.phone_number, from: @admin_phone.number, body: command)
      @message.mark_processing!
    end

    should 'tell list to handle messages waiting for confirmation' do
      List.any_instance.expects(:handle_confirmation_message)
      @message.process
      assert @message.aasm_state == 'handled'
    end
  end

  context 'incoming join message' do
    setup do
      @list = lists(:one)
      @number = incoming_phone_numbers(:two)
      command = I18n.t('list_commands.join', locale: :en)
      command = command[0] if command.is_a?(Array)
      @message = FactoryGirl.create(:message, to: @number.phone_number, body: "#{command.upcase} mumble mumble")
      @message.mark_processing!
    end

    should 'tell list to send join message' do
      List.any_instance.expects(:handle_join_message).with(@message, :en).returns(true)
      @message.process

      assert @message.aasm_state == 'handled'
    end

    context 'in alternate locale' do
      setup do
        command = I18n.t('list_commands.join', locale: :es)
        command = command[0] if command.is_a?(Array)
        @message.body = "#{command} mumble mumble"
      end
      should 'send join message in correct locale' do
        List.any_instance.expects(:handle_join_message).with(@message, :es).returns(true)
        @message.process
      end
    end

  end

  context 'incoming leave message' do
    setup do
      @list = lists(:one)
      @number = incoming_phone_numbers(:one)
      command = I18n.t('list_commands.leave', locale: :en)
      command = command[0] if command.is_a?(Array)

      @message = FactoryGirl.create(:message, to: @number.phone_number, body: "#{command} mumble mumble")
      @message.mark_processing!
    end

    should 'tell list to send leave message' do
      List.any_instance.expects(:handle_leave_message).with(@message, :en).returns(true)
      @message.process

      assert @message.aasm_state == 'handled'
    end

    context 'in alternate locale' do
      setup do
        command = I18n.t('list_commands.leave', locale: :es)
        command = command[0] if command.is_a?(Array)

        @message.body = "#{command} mumble mumble"
      end
      should 'send join message in correct locale' do
        List.any_instance.expects(:handle_leave_message).with(@message, :es).returns(true)
        @message.process
      end
    end

  end

  context 'incoming regular message' do
    setup do
      @list = lists(:one)
      @number = incoming_phone_numbers(:one)
      @message = FactoryGirl.create(:message, to: @number.phone_number, body: 'mumble mumble mumble')
      @message.mark_processing!
    end
  end

end