class RemoveLoginFieldsFromContacts < ActiveRecord::Migration
  def up
    remove_column :contacts, :crypted_password
    remove_column :contacts, :password_salt
    remove_column :contacts, :persistence_token
    remove_column :contacts, :perishable_token
    remove_column :contacts, :admin
    remove_column :contacts, :login
  end

  def down
    add_column :contacts, :login, :string
    add_column :contacts, :admin, :boolean,             :default => false
    add_column :contacts, :perishable_token, :string
    add_column :contacts, :persistence_token, :string
    add_column :contacts, :password_salt, :string
    add_column :contacts, :crypted_password, :string
  end
end
