class MakeIsAdminDefaultFalse < ActiveRecord::Migration
  def up
    change_column :list_memberships, :is_admin, :boolean, default: false, null: false
  end

  def down
    change_column :list_memberships, :is_admin, :boolean
  end
end