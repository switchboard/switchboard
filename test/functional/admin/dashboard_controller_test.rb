require 'test_helper'

class Admin::DashboardControllerTest < ActionController::TestCase

  test 'prevents non-users from viewing admin dashboard' do
    get :index
    assert_redirected_to signin_path
  end

  test 'prevents non-admins from viewing dashboard' do
    login_as :org_one_user
    get :index
    assert_redirected_to signin_path
  end

  test 'admins can view dashboard' do
    login_as :admin
    get :index
    assert_links_to admin_organizations_path
  end

end
