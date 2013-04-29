class AddOutgoingCountToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :outgoing_count, :integer
  end
end