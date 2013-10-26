require 'test_helper'

class Admin::OrganizationsControllerTest < ActionController::TestCase

  setup do
    login_as :admin
  end

  test 'lists organizations' do
    get :index
    @organization = organizations(:one)
    assert_links_to admin_organization_path(@organization)
    assert response.body.include?(@organization.name)
  end

  test 'shows an organization' do
    @organization = organizations(:one)
    get :show, id: @organization.id
    assert_links_to edit_admin_organization_path(@organization)
    assert response.body.include?(@organization.lists.first.name)
  end

  test 'shows edit form for organization' do
    @organization = organizations(:one)
    get :edit, id: @organization.id
    assert_select "form[action='#{admin_organization_path(@organization)}']"
  end

  test 'updates an organization' do
    @organization = organizations(:one)
    @new_name = 'HEYNEWORG'
    put :update, id: @organization.id, organization: {name: @new_name}
    assert_redirected_to admin_organization_path(@organization)

    @organization.reload
    assert @organization.name == @new_name
  end

  test 'creates a new organization' do
    @new_name = 'HEYNEWORG'
    assert_difference('Organization.count', 1) do
      post :create, organization: {name: @new_name}
      assert Organization.find_by_name(@new_name)
    end
  end

end
