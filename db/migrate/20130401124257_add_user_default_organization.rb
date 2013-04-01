class AddUserDefaultOrganization < ActiveRecord::Migration
  def change
    add_column :users, :default_organization_id, :integer
  end
end