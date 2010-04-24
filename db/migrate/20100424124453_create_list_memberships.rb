class CreateListMemberships < ActiveRecord::Migration
  def self.up
    create_table :list_memberships do |t|
      t.integer :list_id
      t.integer :phone_number_id
      t.timestamps
    end
  end

  def self.down
    drop_table :list_memberships
  end
end
