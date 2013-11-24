require 'active_support/concern'

module MonthlyCountable
  extend ActiveSupport::Concern

  included do
    has_many :sent_counts, as: :countable, dependent: :destroy
    after_create { SentCount.setup_new_countable(self) }
  end

  def last_month_sms
    sent_counts.order('date_ending DESC').first.total_count
  end

  def current_month_sms
    sms_count - last_month_sms
  end

  module ClassMethods
    def calculate_monthly_stats
      find_each do |obj|
        SentCount.calculate_new_month(obj)
      end
    end

  end
end