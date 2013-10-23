require 'test_helper'

class ListsControllerTest < ActionController::TestCase

  setup do
    login_as :org_one_user
    @list = lists(:one)
    @non_org_list = lists(:org_two_list)
  end

  context 'lists#index' do
    setup do
      get :index
    end

    should 'show list of lists' do
      assert_template 'index'
      assert_links_to list_path(lists(:one))
    end

    should 'not show lists in other organization' do
      assert_does_not_link_to list_path(@non_org_list)
    end
  end

  context 'lists#show' do
    should 'link to various list actions' do
      get :show, id: @list.id
      assert_template 'show'
      assert_links_to new_list_message_path(@list)
      assert_links_to list_phone_numbers_path(@list)
      assert_links_to edit_list_path(@list)
    end

    should 'not allow showing list outside organization' do
      get :show, id: @non_org_list.id
      assert_response :not_found
    end
  end

  context 'lists#edit' do
    should 'render form for editing list' do
      get :edit, id: @list.id
      assert_template 'edit'
      assert_select "input[name='list[use_welcome_message]']"
    end

    should 'not allow editing list outside organization' do
      get :edit, id: @non_org_list.id
      assert_response :not_found
    end
  end

  # Would rather be testing this via integration test, leaving this bare-bones
  context 'lists#update' do
    should 'update changed attributes on list' do
      put :update, id: @list.id, list: {use_welcome_message: '1', custom_welcome_message: 'Testing'}
      assert_redirected_to list_path(@list)

      @list.reload
      assert @list.use_welcome_message == true
      assert @list.custom_welcome_message == 'Testing'
    end

    should 'show form if there is a validation error' do
      List.any_instance.stubs(:update_attributes).returns(false)
      put :update, id: @list.id, list: {}
      assert_template 'edit'
    end

    should 'not allow updating list outside organization' do
      put :update, id: @non_org_list.id, list: {}
      assert_response :not_found
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
    should 'soft-delete list and redirect' do
      delete :destroy, id: @list.id
      assert_redirected_to lists_path
      assert ! List.find_by_id(@list.id)
      assert List.unscoped.find_by_id(@list.id)
    end

    should 'not allow deleting list outside organization' do
      delete :destroy, id: @non_org_list.id
      assert_response :not_found
    end
  end

  # Would rather be testing this via integration test, leaving this bare-bones
  context 'lists#create' do
    should 'create a new list' do
      put :create, list: {name: 'ANEWUNUSEDNAME', all_users_can_send_messages: '1'}
      @list = assigns(:new_list)

      assert_redirected_to list_path(@list)

      assert @list.name == 'ANEWUNUSEDNAME'
      assert @list.all_users_can_send_messages == true
    end

    should 'show new form if there is a validation error on create' do
      List.any_instance.stubs(:create).returns(false)
      post :create, list: {}
      assert_template 'new'
    end
  end


  context 'lists#import' do
    should 'render form for uploading CSV' do
      get :import, id: @list.id
      assert_template 'import'
      assert_select "input[name='list[csv_file]']"
    end

    should 'not allow importing CSV into list outside organization' do
      get :import, id: @non_org_list.id
      assert_response :not_found
    end
  end

  context 'lists#upload_csv' do
    should 'show error when list is invalid' do
      @errors = ['This is an error', 'This is another']
      List.any_instance.stubs(:update_attributes).returns(true)
      List.any_instance.stubs(:import_from_attachment).returns({success_count: 3, errors: @errors})

      put :upload_csv, id: @list.id
      assert_select '*', /errors importing/
    end

    should 'redirect when csv is successful' do
      List.any_instance.stubs(:update_attributes).returns(true)
      List.any_instance.stubs(:import_from_attachment).returns({success_count: 3, errors: [] })

      put :upload_csv, id: @list.id
      assert_redirected_to list_phone_numbers_path(@list)
    end

  end

end
