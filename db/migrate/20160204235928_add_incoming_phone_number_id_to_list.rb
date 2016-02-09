class AddIncomingPhoneNumberIdToList < ActiveRecord::Migration
  def change
    add_column :lists, :incoming_phone_number_id, :integer
  end
end