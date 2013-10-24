require 'active_support/concern'

module MonthlyCountable
  extend ActiveSupport::Concern

  included do
    has_many :sent_counts, as: :countable, dependent: :destroy
    after_create { SentCount.setup_new_countable(self) }
  end

  def last_month_outgoing
    sent_counts.order('date_ending DESC').first.total_count
  end

  def current_month_outgoing
    outgoing_count - last_month_outgoing
  end

end