class AddOptionsToLists < ActiveRecord::Migration
  def self.up
    add_column :lists, :long_name, :string

    add_column :lists, :allow_email_gateway, :boolean
    add_column :lists, :allow_commercial_gateway, :boolean
    add_column :lists, :prefer_email, :boolean

    
    add_column :lists, :incoming_phone_number, :string
    add_column :lists, :use_incoming_keyword, :boolean

    add_column :lists, :email_admin_with_response, :boolean
    add_column :lists, :text_admin_with_response, :boolean
    add_column :lists, :save_response_in_interface, :boolean

    add_column :lists, :all_users_can_send_messages, :boolean  ## responses go to other members of list, instead of only admins sending messages
    add_column :lists, :open_membership, :boolean  ## list is public, can be joined
    add_column :lists, :moderated_membership, :boolean   ## joins must be approved
 
  end

  def self.down
    remove_column :lists, :allow_email_gateway
    remove_column :lists, :allow_commercial_gateway
    remove_column :lists, :prefer_email

    remove_column :lists, :incoming_phone_number
    remove_column :lists, :use_incoming_keyword

    remove_column :lists, :email_admin_with_response
    remove_column :lists, :text_admin_with_response
    remove_column :lists, :save_response_in_interface

    remove_column :lists, :all_users_can_send_messages

    remove_column :lists, :open_membership
    remove_column :lists, :moderated_membership

  end
end
