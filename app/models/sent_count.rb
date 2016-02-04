class SentCount < ActiveRecord::Base
  attr_accessible :date_ending, :countable_id, :month_count, :total_count

  belongs_to :countable, polymorphic: :ture

  validates :date_ending, presence: true, uniqueness: {scope: [:countable_id, :countable_type]}

  def self.calculate_finished_month(obj)
    date_ending = (Date.today - 1.month).end_of_month
    finished_month = obj.sent_counts.build(date_ending: date_ending)
    finished_month.month_count = obj.sms_count_for_rollup
    finished_month.total_count = finished_month.previous_month.total_count + finished_month.month_count
    finished_month.save!
  end

  def previous_month
    month = (date_ending - 1.month).end_of_month
    countable.sent_counts.where('date_ending <= ?', month).order('date_ending DESC').first || countable.sent_counts.build
  end
end