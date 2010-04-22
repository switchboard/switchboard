class CreatePhoneMessageBoxes < ActiveRecord::Migration
  def self.up
    create_table :phone_message_boxes do |t|
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :phone_message_boxes
  end
end
