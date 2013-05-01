class AddOutgoingCountToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :outgoing_total, :integer
  end
end