require 'test_helper'

class MonthlyCountableTest < ActiveSupport::TestCase

  test 'creates a monthly rollup on create' do
    @list = FactoryGirl.create(:list)
    assert @list.last_month_sms == 0
  end

end