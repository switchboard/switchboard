class CreateServicePhoneNumbers < ActiveRecord::Migration
  def change
    create_table :service_phone_numbers do |t|
      t.string :phone_number
      t.string :service

      t.timestamps
    end
  end
end
