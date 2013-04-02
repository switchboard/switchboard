require 'test_helper'

class RegistrationControllerTest < ActionController::TestCase

  context 'a new invited user' do
    setup do
      @invitation = invitations(:one)
    end

    should 'show registration form' do
      get :new_invited, invitation_token: @invitation.token
      assert_select "input[name='user[name]']"
      assert_select "input[name='user[email]']"
      assert response.body.include?(@invitation.organization.name)
    end

    should 'repost form when user is invalid' do
      User.any_instance.stubs(:save).returns(false)

      post :create, invitation_token: @invitation.token, user: {name: 'New User', email: 'test5@example.com'}
      assert_response :success
      assert_select "input[name='user[name]']"
    end

    should 'create new user when form is submitted' do
      post :create, invitation_token: @invitation.token, user: {name: 'New User', email: 'test5@example.com', password: 'test123', password_confirmation: 'test123'}

      assert_redirected_to lists_path

      new_user = User.find_by_email('test5@example.com')
      assert new_user
      assert new_user.organizations.include?(@invitation.organization)
      assert new_user.organizations.size == 1
      assert new_user.default_organization == @invitation.organization
    end
  end
end
