class AddDeletedBitToLists < ActiveRecord::Migration
  def change
    add_column :lists, :deleted, :boolean, default: false
  end
end