require 'test_helper'

class MonthlyCountableTest < ActiveSupport::TestCase

  test 'creates a monthly rollup on create' do
    @list = FactoryGirl.create(:list)
    assert @list.last_month_sms == 0
  end

  test 'calculates current month compared to previous' do
    @list = FactoryGirl.create(:list)

    SentCount.any_instance.stubs(:total_count).returns(5)
    @list.stubs(:sms_count).returns(20)
    assert @list.current_month_sms == 15, "Message count for current month should be 15, is #{@list.current_month_sms}"
  end
end