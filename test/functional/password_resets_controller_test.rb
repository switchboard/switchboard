require 'test_helper'

class PasswordResetsControllerTest < ActionController::TestCase

        
  context "requesting a new password" do
    should "render new template" do
      get :new
      assert_template 'new'
    end
  end

  context "requesting a password reset" do
    should "redirect and create token" do
      @user = users(:admin_two)
      post :create, {password_reset: {email: @user.email} }
      assert_redirected_to signin_path
      assert @user.reload.password_reset_token.present?
      assert @user.password_reset_sent_at > 10.seconds.ago

      assert !ActionMailer::Base.deliveries.empty?
    end
  end
  
  context "resetting password" do
    should "show password form" do
      @user = users(:admin_two)
      @user.send(:send_password_reset)
      @user.reload

      get 'edit', id: @user.password_reset_token

      assert_select "input[name='user[password]']"
      assert_select "input[name='user[password_confirmation]']"
    end
    
    should "reset password" do
      @user = users(:admin_two)
      @user.send(:send_password_reset)
      @user.reload
      @new_password = 'test99'

      put 'update', id: @user.password_reset_token, user: { password: @new_password, password_confirmation: @new_password }
      assert_redirected_to signin_path
      assert User.authenticate(@user.email, @new_password)
    end

    should "return an error if password is not valid" do
      @user = users(:admin_two)
      @user.send(:send_password_reset)
      @user.reload
      @new_password = 'short'

      put 'update', id: @user.password_reset_token, user: { password: @new_password, password_confirmation: @new_password }

      assert_template 'edit'
      assert_select '.flash', /invalid/
    end


  end
                
end
