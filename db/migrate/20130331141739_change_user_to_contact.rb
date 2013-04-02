class ChangeUserToContact < ActiveRecord::Migration
  def up
    rename_table :users, :contacts
    rename_column :phone_numbers, :user_id, :contact_id
  end

  def down
    rename_table :contacts, :users
    rename_column :phone_numbers, :contact_id, :user_id
  end
end