class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.string :email
      t.string :token
      t.integer :organization_id
      t.timestamps
    end
  end
end
