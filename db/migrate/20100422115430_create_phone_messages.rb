class CreatePhoneMessages < ActiveRecord::Migration
  def self.up
    create_table :phone_messages do |t|
      t.string :body
      t.string :from
      t.string :to
      t.integer :phone_message_box_id
      t.integer :phone_id
      t.boolean :read, :default => 0 
      t.timestamps
    end
  end

  def self.down
    drop_table :phone_messages
  end
end
