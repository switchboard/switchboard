class AddListConfigurationOptions < ActiveRecord::Migration
  def self.up
    add_column :lists, :add_list_name_header, :boolean
    add_column :lists, :identify_sender, :boolean
  end

  def self.down
    drop_column :lists, :add_list_name_header
    drop_column :lists, :identify_sender 
  end
end
