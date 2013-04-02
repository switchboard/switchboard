require 'test_helper'

class OrganizationsControllerTest < ActionController::TestCase

  context 'viewing organization' do
    setup do
      login_as :org_one_user
      @organization = organizations(:one)
    end

    should 'show list of members' do
      get :show, id: @organization.id
      assert response.body.include?(@organization.users[0].name)
      assert response.body.include?(@organization.users[1].name)
    end

    should 'show form to add user' do
      get :show, id: @organization.id
      assert_select "form[action='#{invite_organization_path(@organization)}']"
      assert_select "input[name='invitation[email]']"
    end

    should 'prevent access to organizations in which user is not a member' do
      get :show, id: organizations(:two).id
      assert_response :not_found
    end

    should 'allow inviting new user' do
      @new_email = 'newuser@example.com'
      assert_difference('Invitation.count', 1) do
        post :invite, id: @organization.id, invitation: {email: @new_email}
      end
      assert_redirected_to organization_path(@organization)

      invitation = Invitation.find_by_email(@new_email)
      assert invitation
      assert invitation.organization == @organization
      assert invitation.email == @new_email
      assert ActionMailer::Base.deliveries.last.to.include?(@new_email)
    end

    should 'allow inviting existing user to organization, without creating an invitation' do
      @existing_user = users(:org_two_user)

      assert_difference('Invitation.count', 0) do
        post :invite, id: @organization.id, invitation: {email: @existing_user.email}
      end

      assert_redirected_to organization_path(@organization)
      assert @existing_user.organizations.include?(@organization)

      @email = ActionMailer::Base.deliveries.last
      assert @email.to.include?(@existing_user.email)
      assert_match(/#{@organization.name}/, @email.encoded)
    end

    should_eventually 'allow deleting members' do
      
    end

  end

end
