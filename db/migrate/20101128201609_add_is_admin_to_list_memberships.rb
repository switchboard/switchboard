class AddIsAdminToListMemberships < ActiveRecord::Migration
  def self.up
    add_column :list_memberships, :is_admin, :boolean
  end

  def self.down
    remove_column :list_memberships, :is_admin
  end
end
