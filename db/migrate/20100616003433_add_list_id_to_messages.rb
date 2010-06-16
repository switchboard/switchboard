class AddListIdToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :list_id, :int
  end

  def self.down
    remove_column :messages, :list_id
  end
end
