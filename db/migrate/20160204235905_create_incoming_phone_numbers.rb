class CreateIncomingPhoneNumbers < ActiveRecord::Migration
  def change
    create_table :incoming_phone_numbers do |t|
      t.string :sid
      t.string :phone_number
      t.text :notes

      t.timestamps
    end
  end
end
