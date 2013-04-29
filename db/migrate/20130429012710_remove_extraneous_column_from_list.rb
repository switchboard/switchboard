class RemoveExtraneousColumnFromList < ActiveRecord::Migration
  def up
    remove_column :lists, :incoming_phone_number
  end

  def down
    add_column :lists, :incoming_phone_number, :string
  end
end
