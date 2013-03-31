class CreateAuthorizations < ActiveRecord::Migration
  def change
    create_table :authorizations do |t|
      t.string   :provider
      t.string   :uid
      t.integer  :user_id
      t.datetime :created_at
      t.datetime :updated_at
    end
    
  end
end