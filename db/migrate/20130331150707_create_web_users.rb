class CreateWebUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.string :password_reset_token
      t.datetime :password_reset_sent_at
      t.string :auth_token
      t.boolean :superuser

      t.timestamps
    end
  end
end
