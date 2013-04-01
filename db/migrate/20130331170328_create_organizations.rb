class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name
      t.timestamps
    end

    create_table :organizations_users, id: false do |t|
      t.integer :user_id
      t.integer :organization_id
    end
    add_index :organizations_users, [:user_id], name: 'index_organizations_users_on_user_id'

    add_column :lists, :organization_id, :integer
    add_index :lists, [:organization_id], name: 'index_lists_on_organization_id'

  end
end