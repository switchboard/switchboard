class AddDefaultsToLists < ActiveRecord::Migration
  def self.up
    change_column :lists, :allow_email_gateway, :boolean, :default => 1
    change_column :lists, :allow_commercial_gateway, :boolean, :default => 1
    change_column :lists, :prefer_email, :boolean, :default => 1
    change_column :lists, :all_users_can_send_messages, :boolean, :default => 1 ## responses go to other members of list, instead of only admins sending messages
    change_column :lists, :open_membership, :boolean, :default => true  ## list is public, can be joined
  end

  def self.down
    change_column :lists, :allow_email_gateway, :boolean
    change_column :lists, :allow_commercial_gateway, :boolean
    change_column :lists, :prefer_email, :boolean
    change_column :lists, :all_users_can_send_messages, :boolean ## responses go to other members of list, instead of only admins sending messages
    change_column :lists, :open_membership, :boolean  ## list is public, can be join
  end
end

