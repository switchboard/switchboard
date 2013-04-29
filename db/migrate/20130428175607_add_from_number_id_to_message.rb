class AddFromNumberIdToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :from_phone_number_id, :integer
  end
end