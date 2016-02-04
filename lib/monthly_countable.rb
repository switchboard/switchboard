require 'active_support/concern'

module MonthlyCountable
  extend ActiveSupport::Concern

  included do
    has_many :sent_counts, as: :countable, dependent: :destroy
  end

  def last_month_sms
    latest_month_count.month_count
  end

  def last_month_sms_total
    latest_month_count.total_count
  end

  def latest_month_count
    sent_counts.order('date_ending DESC').first || self.sent_counts.build
  end

  def total_sms
    current_month_sms + last_month_sms_total
  end

  module ClassMethods
    def calculate_monthly_stats
      find_each do |obj|
        SentCount.calculate_finished_month(obj)
      end
    end
  end
end