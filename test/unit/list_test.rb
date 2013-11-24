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

  context 'sending welcome message' do
    setup do
      @list = FactoryGirl.build(:list, use_welcome_message: true, custom_welcome_message: nil)
    end

    should 'use the custom message when it is filled in' do
      @list.custom_welcome_message = "HEY WELCOME THERE"
      assert @list.welcome_message(:en) == @list.custom_welcome_message
    end

    should 'select the default message if there is no custom message' do
      assert @list.welcome_message(:en) == I18n.t('list_responses.default_welcome', name: @list.name, locale: :en)
    end

    should 'send welcome message in the correct locale' do
      assert @list.welcome_message(:es) == I18n.t('list_responses.default_welcome', name: @list.name, locale: :es)
    end

    should 'send default welcome message in the default locale if none is passed' do
      @list.custom_welcome_message = ''
      @list.default_locale = 'es'
      assert @list.welcome_message == I18n.t('list_responses.default_welcome', name: @list.name, locale: :es), "List welcome message is #{@list.welcome_message}, should be #{I18n.t('list_responses.default_welcome', name: @list.name, locale: :es)}"
      @list.default_locale = 'en'
      assert @list.welcome_message == I18n.t('list_responses.default_welcome', name: @list.name, locale: :en)
    end

  end

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

      should 'respond that message can be sent' do
        assert @list.can_send_message?(@message)
      end

      should 'set outgoing total on message' do
        @list.handle_send_action(@message)
        @message.reload
        assert @message.outgoing_total == @list.list_memberships.size
      end

      should 'send an outgoing message for each' do
        @list.expects(:create_outgoing_message).times(@list.list_memberships.size)
        @list.handle_send_action(@message)
      end
    end

  end

  context 'handling admin message' do
    context 'when message should go to admin' do
      setup do
        @list = lists(:two)
        @phone = list_memberships(:two_two).phone_number # not an admin
        @admin_phone = list_memberships(:two_admin).phone_number
        @message = FactoryGirl.create(:message, list: @list, from: @phone.number)
      end

      should 'respond that message can go to admin' do
        assert @list.can_admin_message?(@message)
      end

      should "send admin the response, with a message that includes the sender's number" do
        @list.expects(:create_outgoing_message).with(@admin_phone, regexp_matches(Regexp.new(@phone.number)))
        @list.handle_admin_message(@message)
      end
    end
  end

  context 'handling leave message' do
    setup do
      @list = lists(:one)
    end

    context 'when number is not a member' do
      setup do
        @phone = FactoryGirl.create(:phone_number)
        @message = FactoryGirl.create(:message, list: @list, from: @phone.number)
      end
      should 'create outgoing message saying user is not a member' do
        @list.expects(:create_outgoing_message).with(@phone, I18n.t('list_responses.remove_not_subscribed', name: @list.name, locale: :en))
        @list.handle_leave_message(@message)
      end
    end

    context 'when number is a member' do
      setup do
        @phone = @list.list_memberships.first.phone_number
        @message = FactoryGirl.create(:message, list: @list, from: @phone.number)
      end

      should 'create outgoing message saying user was removed' do
        # test is a little heavy-handed
        @list.expects(:create_outgoing_message).with(@phone, I18n.t('list_responses.removed', name: @list.name, locale: :en))
        @list.expects(:remove_phone_number).with(@phone)
        @list.handle_leave_message(@message, :en)

      end
      should 'create message in an alternate locale' do
        @list.expects(:create_outgoing_message).with(@phone, I18n.t('list_responses.removed', name: @list.name, locale: :es))
        @list.expects(:remove_phone_number).with(@phone)
        @list.handle_leave_message(@message, :es)
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

      should 'create outgoing message saying user is already a member in alternate locale' do
        @list.expects(:create_outgoing_message).with(@phone, I18n.t('list_responses.join_already_subscribed', name: @list.name, locale: :es))
        @list.handle_join_message(@message, :es)
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

      should 'create outgoing message saying list is private, in alternate locale' do
        @list.expects(:create_outgoing_message).with(@phone, I18n.t('list_responses.join_private', name: @list.name, locale: :es))
        @list.handle_join_message(@message, :es)
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

      should 'send welcome message in correct locale' do
        @list.expects(:create_outgoing_message).never
        List.any_instance.expects(:send_welcome_message).with(@phone, :es).returns(true)

        @list.handle_join_message(@message, :es)
      end
    end

  end

end