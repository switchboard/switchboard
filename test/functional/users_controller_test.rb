require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  setup do
    login_as :admin
  end

  context 'users#new' do
    should "render user form" do
      get :new
      assert_template 'new'
      assert_select "input[name='user[first_name]']"
    end
  end

  context 'users#create' do
    should 'show error when user is invalid' do
      User.any_instance.stubs(:valid?).returns(false)
      post :create
      assert_select '.flash', /problem/
    end

    should 'add user to list' do
      @list = lists(:one)
      List.any_instance.expects(:add_phone_number)
      @user = FactoryGirl.build(:user)
      post :create, list_id: @list.id, user: @user.attributes.slice(*User.accessible_attributes).merge({phone_numbers_attributes: {'0' => {'number' => '1231231234'}} })
    end

    should 'redirect when user is saved' do
      User.any_instance.stubs(:save).returns(true)
      post :create
      assert_redirected_to lists_path
    end
  end

end
