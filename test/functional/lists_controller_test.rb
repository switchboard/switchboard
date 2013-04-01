require 'test_helper'

class ListsControllerTest < ActionController::TestCase

  setup do
    login_as :admin
    @list = lists(:one)
  end

  context 'lists#index' do
    should 'show list of lists' do
      get :index
      assert_template 'index'
      assert_links_to list_path(lists(:one))
    end
  end
  
  context 'lists#show' do
    should 'link to various list actions' do
      get :show, list_id: @list.id
      assert_template 'show'
      assert_links_to new_list_message_path(@list)
      assert_links_to list_phone_numbers_path(@list)
      assert_links_to edit_list_path(@list)
    end
  end
  
  context 'lists#edit' do
    should 'render form for editing list' do
      get :edit, list_id: @list.id
      assert_template 'edit'
      assert_select "input[name='list[use_welcome_message]']"
    end
  end
  
  # Would rather be testing this via integration test, leaving this bare-bones
  context 'lists#update' do
    should 'update changed attributes on list' do
      put :update, list_id: @list.id, list: {use_welcome_message: '1', custom_welcome_message: 'Testing'}
      assert_redirected_to list_path(@list)
  
      @list.reload
      assert @list.use_welcome_message == true
      assert @list.custom_welcome_message == 'Testing'
    end
  
    should 'show form if there is a validation error' do
      List.any_instance.stubs(:update_attributes).returns(false)
      put :update, list_id: @list.id, list: {}
      assert_template 'edit'
    end
  end
  
  context 'lists#new' do
    should 'render form for creating new' do
      get :new
      assert_template 'new'
      assert_select "input[name='list[name]']"
      assert_select "input[name='list[all_users_can_send_messages]']"
    end
  end
  
  context 'lists#destroy' do
    should 'delete list and redirect' do
      delete :destroy, id: @list.id
      assert_redirected_to lists_path
      assert List.find_by_id(@list.id) == nil
    end
  end
  
  # Would rather be testing this via integration test, leaving this bare-bones
  context 'lists#create' do
    should 'create a new list' do
      put :create, list: {name: 'ANEWUNUSEDNAME', all_users_can_send_messages: '1'}
      @new_list = assigns(:new_list)
  
      assert_redirected_to list_path(@new_list)
  
      assert @new_list.name == 'ANEWUNUSEDNAME'
      assert @new_list.all_users_can_send_messages == true
    end
  
    should 'show new form if there is a validation error on create' do
      List.any_instance.stubs(:create).returns(false)
      post :create, list: {}
      assert_template 'new'
    end
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
