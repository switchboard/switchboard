class CreateDbFiles < ActiveRecord::Migration
  
  def self.up
    create_table :db_files do |t|
      t.column :data,  :binary
    end
  end

  def self.down
    drop_table :db_files
  end
end

