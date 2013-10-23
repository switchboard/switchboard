class SentCount < ActiveRecord::Base
  attr_accessible :date_ending, :countable_id, :month_count, :total_count

  belongs_to :countable, polymorphic: :ture

  validates :date_ending, presence: true, uniqueness: {scope: [:countable_id, :countable_type]}

  def self.setup_new_countable(obj)
    obj.sent_counts.create(date_ending: 1.month.ago.end_of_month, total_count: 0, month_count: 0)
  end

  def self.calculate_new_month(obj)
    date_ending = Date.today.end_of_month
    new_month = obj.sent_counts.find_or_initialize_by_date_ending(date_ending: date_ending)

    new_month.total_count = obj.outgoing_count
    new_month.month_count = new_month.total_count - new_month.previous_month.total_count
    new_month.save!
  end

  def previous_month
    previous_month = (date_ending - 1.month).end_of_month
    countable.sent_counts.where(date_ending: previous_month).first
  end
end
