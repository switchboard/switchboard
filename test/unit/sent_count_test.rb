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

end
