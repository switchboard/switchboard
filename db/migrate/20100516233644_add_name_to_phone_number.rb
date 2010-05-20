class AddNameToPhoneNumber < ActiveRecord::Migration
  def self.up
    add_column :phone_numbers, :first_name, :string
    add_column :phone_numbers, :last_name, :string
  end

  def self.down
    remove_column :phone_numbers, :last_name
    remove_column :phone_numbers, :first_name
  end
end
