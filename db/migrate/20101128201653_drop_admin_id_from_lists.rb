class DropAdminIdFromLists < ActiveRecord::Migration
  def self.up
    remove_column :lists, :admin_id
  end

  def self.down
    add_column :lists, :admin_id, :int
  end
end
