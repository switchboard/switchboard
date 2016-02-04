class SetSentCountDefaults < ActiveRecord::Migration
  def up
    change_column_default :sent_counts, :month_count, 0
    change_column_default :sent_counts, :total_count, 0
  end

  def down
    # no-op
  end
end