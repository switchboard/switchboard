class AddProviderEmailToPhoneNumber < ActiveRecord::Migration
  def self.up
    add_column :phone_numbers, :provider_email, :string
    add_column :phone_numbers, :gateway_preference, :string
  end

  def self.down
    remove_column :phone_numbers, :provider_email
    remove_column :phone_numbers, :gateway_preference  
  end
end
