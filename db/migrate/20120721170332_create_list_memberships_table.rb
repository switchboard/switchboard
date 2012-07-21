class CreateListMembershipsTable < ActiveRecord::Migration
  def change
    create_table :list_memberships do |t|
      t.integer :list_id
      t.integer :phone_number_id
      t.timestamps
    end
  end
end
