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
end