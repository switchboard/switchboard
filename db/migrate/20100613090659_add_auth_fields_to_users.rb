class AddAuthFieldsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :crypted_password, :string
    add_column :users, :password_salt, :string
    add_column :users, :persistence_token, :string
    add_column :users, :perishable_token, :string
    add_column :users, :admin, :boolean, :default => 0
  end

  def self.down
    drop_column :users, :crypted_password
    drop_column :users, :password_salt
    drop_column :users, :persistence_token
    drop_column :users, :perishable_token
    drop_column :users, :admin
  end
end
