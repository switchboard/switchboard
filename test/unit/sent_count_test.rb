require 'test_helper'

class SentCountTest < ActiveSupport::TestCase

  context 'calculating counts for the previous month' do
    setup do
      @list = FactoryGirl.create(:list)
    end

    should 'create a new sent-count for the previous month' do
      Timecop.freeze(Date.today + 1.month) do
        assert @list.last_month_sms == 0
        @list.stubs(:sms_count_for_rollup).returns(20)
        assert_difference('SentCount.count', 1) do
          SentCount.calculate_finished_month(@list)
          assert @list.last_month_sms == 20
        end
      end
    end
  end
end
