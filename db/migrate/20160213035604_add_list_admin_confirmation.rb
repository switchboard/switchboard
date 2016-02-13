class AddListAdminConfirmation < ActiveRecord::Migration
  def up
    add_column :lists, :require_admin_confirmation, :boolean, default: false
  end

  def down
    remove_column :lists, :require_admin_confirmation
  end
end