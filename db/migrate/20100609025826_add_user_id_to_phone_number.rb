class AddUserIdToPhoneNumber < ActiveRecord::Migration
  def self.up
    add_column :phone_numbers, :user_id, :int
  end

  def self.down
    remove_column :phone_numbers, :user_id
  end
end
