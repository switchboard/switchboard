require 'test_helper'

class ListTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  context 'importing a CSV file' do
    should 'handle rows with errors' do

      @list = lists(:one)
      List.any_instance.stubs(:add_phone_number).returns(true)

      @list.csv_file = fixture_file_upload('file_uploads/contact_csv_import_one_error.csv')
      @list.save!
      result = @list.import_from_attachment

      assert result[:errors].length == 1
    end

    should 'handle a successful CSV file' do
      @list = lists(:one)
      List.any_instance.expects(:add_phone_number).times(4).returns(true)

      @list.csv_file = fixture_file_upload('file_uploads/contact_csv_import_valid.csv')
      @list.save!

      result = @list.import_from_attachment

      assert result[:errors].length == 0
      assert result[:success_count] == 4

      added_contact = Contact.find_by_email('pam@example.com')
      assert added_contact
      assert added_contact.phone_numbers.first.number == '2155551215'
    end
  end

  should 'split messages by 160 characters' do
    @list = FactoryGirl.build(:list, add_list_name_header: true)
    @message = FactoryGirl.build(:message, body: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore.')

    # This happens in message handler at the moment
    @message.tokens = @message.body.split(/ /)
    @phone_number = FactoryGirl.build(:phone_number)

    @content = @list.prepare_content(@message, @phone_number)

    assert @content.length == 3
    assert @content[0] == "[#{@list.name}] Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim (1/3)"
    assert @content[2] == 'cillum dolore. (3/3)'
  end

  should 'not try to split shorter messages' do
    @list = FactoryGirl.build(:list, add_list_name_header: true)
    @message = FactoryGirl.build(:message, body: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam')

    # This happens in message handler at the moment
    @message.tokens = @message.body.split(/ /)
    @phone_number = FactoryGirl.build(:phone_number)

    @content = @list.prepare_content(@message, @phone_number)
    puts @content.inspect
    assert @content.length == 1
    assert @content[0] == "[#{@list.name}] #{@message.body}"
  end
end