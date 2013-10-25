require 'test_helper'

class SentCountTest < ActiveSupport::TestCase

  context 'adding a new list' do
    should 'create an empty list-count when a list is created' do
      @list = FactoryGirl.create(:list)
      sent_count = @list.sent_counts.first
      assert sent_count
      assert sent_count.total_count == 0
    end
  end

  context 'calculating counts for the previous month' do
    setup do
      @list = FactoryGirl.create(:list)
    end

    should 'create a new sent-count for the previous month' do
      Timecop.freeze(Date.today + 1.month) do
        assert @list.last_month_outgoing == 0
        @list.stubs(:outgoing_count).returns(20)
        assert_difference('SentCount.count', 1) do
          SentCount.calculate_new_month(@list)
          assert @list.last_month_outgoing == 20
        end
      end
    end
  end
end
