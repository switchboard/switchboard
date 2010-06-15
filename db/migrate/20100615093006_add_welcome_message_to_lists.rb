class AddWelcomeMessageToLists < ActiveRecord::Migration
  def self.up
    add_column :lists, :use_welcome_message, :boolean, :default => 0
    add_column :lists, :custom_welcome_message, :string
  end

  def self.down
    remove_column :lists, :use_welcome_message
    remove_column :lists, :custom_welcome_message
  end
end
