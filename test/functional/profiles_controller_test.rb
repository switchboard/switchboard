require 'test_helper'

class ProfilesControllerTest < ActionController::TestCase

  setup do
    @user = users(:admin)
    login_as :admin
  end

  context 'profile#edit' do

    should 'show profile form' do
      get :edit
      assert_select "input[name='user[name]']"
      assert_select "input[name='user[email]']"
    end
    
  end

  context 'profile#update' do

    should 'update user attributes' do
      put :update, user: {email: @user.email, name: 'New name'}
      assert_redirected_to edit_profile_path

      @user.reload
      assert @user.name == 'New name'
    end

    should 'update password if pw & confirmation are passed' do
      @old_password_hash = @user.password_digest
      put :update, id: @user.id, user: {email: @user.email, name: @user.name, password: 'changedpw', password_confirmation: 'changedpw'}
      assert_redirected_to edit_profile_path
    
      @user.reload
      assert @user.password_digest != @old_password_hash
    end

    should 'show new form if there is a validation error' do
      User.any_instance.stubs(:update_attributes).returns(false)
      put :update, id: @user.id, user: {}

      assert_template 'edit'
    end

  end
end
