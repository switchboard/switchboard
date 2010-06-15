class AddAuthFieldsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :crypted_password, :string
    add_column :users, :password_salt, :string
    add_column :users, :persistence_token, :string
    add_column :users, :perishable_token, :string
    add_column :users, :admin, :boolean, :default => 0
  end

  def self.down
    remove_column :users, :crypted_password
    remove_column :users, :password_salt
    remove_column :users, :persistence_token
    remove_column :users, :perishable_token
    remove_column :users, :admin
  end
end
