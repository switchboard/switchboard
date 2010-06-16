class AddListIdToMessages < ActiveRecord::Migration
  def self.up
  ## i think this should already have been added in a previous migration
 #   add_column :messages, :list_id, :int
  end

  def self.down
 #   remove_column :messages, :list_id
  end
end
