require 'test_helper'

class ListsControllerTest < ActionController::TestCase

  setup do
    login_as :admin
    @list = lists(:one)
  end

  context 'lists#import' do
    should 'render form for uploading CSV' do
      get :import, list_id: @list.id 
      assert_template 'import'
      assert_select "input[name='list[csv_file]']"
    end
  end

  context 'lists#upload_csv' do
    should 'show error when list is invalid' do
      @errors = ['This is an error', 'This is another']
      List.any_instance.stubs(:update_attributes).returns(true)
      List.any_instance.stubs(:import_from_attachment).returns({success_count: 3, errors: @errors})

      put :upload_csv, list_id: @list.id
      assert_select '*', /errors importing/
    end

    should 'redirect when csv is successful' do
      List.any_instance.stubs(:update_attributes).returns(true)
      List.any_instance.stubs(:import_from_attachment).returns({success_count: 3, errors: [] })

      put :upload_csv, list_id: @list.id
      assert_redirected_to list_phone_numbers_path(@list)
    end

  end

end
