class AddIsAdminToListMembershipsAgain < ActiveRecord::Migration
  def change
    add_column :list_memberships, :is_admin, :boolean, default: false
  end
end
