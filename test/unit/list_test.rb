require 'test_helper'

class ListTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  test 'hides deleted lists by default' do
    @list = lists(:one)
    @list.soft_delete
    assert ! List.all.include?(@list)
  end

  context 'importing a CSV file' do
    setup do
      ListMembership.any_instance.stubs(:send_welcome_message).returns(true)
    end

    should 'handle rows with errors' do

      @list = lists(:one)
      assert_difference('@list.list_memberships.size', 3) do
        @list.csv_file = fixture_file_upload('file_uploads/contact_csv_import_one_error.csv')
        @list.save!
        result = @list.import_from_attachment
        assert result[:errors].length == 1
      end

    end

    should 'handle a successful CSV file' do
      @list = lists(:one)

      assert_difference('@list.list_memberships.size', 4) do
        @list.csv_file = fixture_file_upload('file_uploads/contact_csv_import_valid.csv')
        @list.save!
        result = @list.import_from_attachment
        assert result[:errors].length == 0
        assert result[:success_count] == 4
      end

      added_contact = Contact.find_by_email('pam@example.com')
      assert added_contact
      assert added_contact.phone_numbers.first.number == '2155551215'
    end
  end

  should 'split messages by 160 characters' do
    @list = FactoryGirl.build(:list, add_list_name_header: true)
    @message = FactoryGirl.build(:message, body: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore.')

    @phone_number = FactoryGirl.build(:phone_number)

    @content = @list.prepare_content(@message)

    assert @content.length == 3
    assert @content[0] == "[#{@list.name}] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim (1/3)"
    assert @content[2] == 'cillum dolore. (3/3)'
  end

  should 'not try to split shorter messages' do
    @list = FactoryGirl.build(:list, add_list_name_header: true)
    @message = FactoryGirl.build(:message, body: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam')

    @phone_number = FactoryGirl.build(:phone_number)

    @content = @list.prepare_content(@message)
    assert @content.length == 1
    assert @content[0] == "[#{@list.name}] #{@message.body}"
  end

  #  def create_outgoing_message(phone_number, body, message_id = nil)

  context 'sending a message' do

    # TODO this seems speculative ATM as there's no UI
    # to set phone.provider_email
    context 'when list allows email' do
      setup do
        @list = lists(:two) # allows & prefers email
        @list.all_users_can_send_messages = true

        @body = 'This is a new message'
        @message = FactoryGirl.create(:message, list: @list, body: @body)
        @outgoing_count = @list.phone_numbers.count
      end

      should 'enqueue email if phone has provider email' do
        @phone = FactoryGirl.build(:phone_number, provider_email: 'example.com')
        Resque.expects(:enqueue).with(OutgoingMessageJob, @list.id, "#{@phone.number}@#{@phone.provider_email}", instance_of(String), @body, @message.id, @outgoing_count)
        @list.create_outgoing_message(@phone, @body, @message.id, @outgoing_count)
      end

      should 'enqueue sms if phone does not have provider email' do
        @phone = FactoryGirl.build(:phone_number)

        Resque.expects(:enqueue).with(OutgoingMessageJob, @list.id, @phone.number, instance_of(String), @body, @message.id, @outgoing_count)
        @list.create_outgoing_message(@phone, @body, @message.id, @outgoing_count)
      end
    end

    context 'when list does not receive email' do
      setup do
        @list = lists(:one)
        @body = 'A new message'
        @message = FactoryGirl.create(:message, list: @list, body: @body)
      end

      should 'enqueue sms' do
        @phone = FactoryGirl.build(:phone_number)

        Resque.expects(:enqueue).with(OutgoingMessageJob, @list.id, @phone.number, instance_of(String), @body, @message.id, @outgoing_count)
        @list.create_outgoing_message(@phone, @body, @message.id, @outgoing_count)
      end
    end
  end

  context 'handling sent message' do
    context 'when message can be sent to list' do
      setup do
        @list = lists(:one)
        @message = FactoryGirl.create(:message, list: @list)
      end

      should 'set outgoing total on message' do
        @list.handle_send_action(@message)
        @message.reload
        assert @message.outgoing_total == @list.list_memberships.size
      end

      should 'send an outgoing message for each' do
        @list.expects(:create_outgoing_message).times(@list.list_memberships.size)
        success = @list.handle_send_action(@message)
        assert success
      end

    end

    context 'when message should go to admin' do
      setup do
        @list = lists(:two)
        @phone = list_memberships(:two_two).phone_number # not an admin
        @admin_phone = list_memberships(:two_admin).phone_number
        @message = FactoryGirl.create(:message, list: @list, from: @phone.number)
      end

      should "send admin the response, with a message that includes the sender's number" do
        @list.expects(:create_outgoing_message).with(@admin_phone, regexp_matches(Regexp.new(@phone.number)))
        success = @list.handle_send_action(@message)
        assert success
      end
    end

    context 'when message can not go to list or to admin' do
      setup do
        @list = lists(:two)
        @list.update_column(:text_admin_with_response, false)
        @phone = list_memberships(:two_two).phone_number # not an admin
        @message = FactoryGirl.create(:message, list: @list, from: @phone.number)
      end

      should 'return false' do
        @list.expects(:create_outgoing_message).never
        success = @list.handle_send_action(@message)
        assert ! success
      end
    end
  end

  context 'handling join message' do
    setup do
      @list = lists(:one)
    end

    context 'when number is already a member' do
      setup do
        @phone = @list.list_memberships.first.phone_number
        @message = FactoryGirl.create(:message, list: @list, from: @phone.number)
      end

      should 'create outgoing message saying user is already a member' do
        @list.expects(:create_outgoing_message).with(@phone, regexp_matches(/already/))
        @list.handle_join_message(@message)
      end
    end

    context 'with a closed list' do
      setup do
        @list.update_column(:open_membership, false)
        @phone = FactoryGirl.create(:phone_number)
        @message = FactoryGirl.create(:message, list: @list, from: @phone.number)
      end

      should 'create outgoing message saying list is private' do
        @list.expects(:create_outgoing_message).with(@phone, regexp_matches(/private/))
        @list.handle_join_message(@message)
      end
    end

    context 'with new member' do
      setup do
        @list.update_column(:open_membership, true)
        @phone = FactoryGirl.create(:phone_number)
        @message = FactoryGirl.create(:message, list: @list, from: @phone.number)
      end

      should 'subscribe member to list' do
        @list.expects(:create_outgoing_message).never
        List.any_instance.expects(:send_welcome_message).returns(true)

        assert_difference('@list.list_memberships.count', 1) do
          @list.handle_join_message(@message)
        end
      end
    end


  end

end