class AddProviderEmailAndPreferencesToPhoneNumber < ActiveRecord::Migration
  def self.up
    add_column :phone_numbers, :provider_email, :string
    add_column :phone_numbers, :gateway_preference, :string
  end

  def self.down
    drop_column :phone_numbers, :provider_email
    drop_column :phone_numbers, :gateway_preference  
  end
end
