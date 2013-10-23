require 'active_support/concern'

module MonthlyCountable
  extend ActiveSupport::Concern

  included do
    has_many :sent_counts, as: :countable, dependent: :destroy
    after_create { SentCount.setup_new_countable(self) }
  end

  def last_count
    sent_counts.order('date_ending DESC').first
  end

  def current_month_outgoing
    outgoing_count - last_count.total_count
  end

end