class AddIncomingNumberToLists < ActiveRecord::Migration
  def self.up
    add_column :lists, :incoming_number, :string
  end

  def self.down
    remove_column :lists, :incoming_number
  end
end
