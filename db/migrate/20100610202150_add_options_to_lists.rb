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
    drop_column :lists, :allow_email_gateway
    drop_column :lists, :allow_commercial_gateway
    drop_column :lists, :prefer_email

    drop_column :lists, :incoming_phone_number
    drop_column :lists, :use_incoming_keyword

    drop_column :lists, :email_admin_with_response
    drop_column :lists, :text_admin_with_response
    drop_column :lists, :save_response_in_interface

    drop_column :lists, :all_users_can_send_messages

    drop_column :lists, :open_membership
    drop_column :lists, :moderated_membership

  end
end
