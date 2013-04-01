require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test 'sets default organization when adding first organization' do
    user = FactoryGirl.create(:user)
    organization = FactoryGirl.create(:organization)

    assert user.default_organization.blank?
    

    user.organizations << organization
    user.reload
    
    assert user.default_organization = organization
  end
end
