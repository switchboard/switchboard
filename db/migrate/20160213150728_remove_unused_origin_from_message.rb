class RemoveUnusedOriginFromMessage < ActiveRecord::Migration
  def up
    remove_column :messages, :origin
    remove_column :messages, :origin_id
    remove_column :messages, :message_state_id
    remove_column :messages, :recipient_id
  end

  def down
    add_column :messages, :origin_id, :string
    add_column :messages, :origin, :string
    add_column :messages, :message_state_id, :integer
    add_column :messages, :recipient_id, :integer
  end
end