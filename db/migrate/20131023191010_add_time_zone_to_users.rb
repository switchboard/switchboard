class AddTimeZoneToUsers < ActiveRecord::Migration
  def change
    add_column :users, :time_zone, :string, default: "Eastern Time (US & Canada)", null: false
  end
end