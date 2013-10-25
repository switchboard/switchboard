class AddSentTimesToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :queued_at, :datetime
    add_column :messages, :sent_at, :datetime
  end
end