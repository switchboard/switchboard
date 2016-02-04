require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase

  test 'allows access to deleted lists' do
    @list = lists(:one)
    @list.soft_delete
    @organization = @list.organization
    assert ! @organization.lists.include?(@list)
    assert @organization.lists_including_deleted.include?(@list)
  end

  test 'calculates total outgoing count of lists' do
    List.any_instance.stubs(:current_month_sms).returns(3)
    @organization = organizations(:one)
    assert @organization.current_month_sms == 6, "Count should be 6, is #{@organization.current_month_sms}"
  end

end
