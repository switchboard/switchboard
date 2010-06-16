class AddAdminToList < ActiveRecord::Migration
  def self.up
    add_column :lists, :admin_id, :int
  end

  def self.down
    remove_column :lists, :admin_id
  end
end
