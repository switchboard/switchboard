class CreateDaemonStatuses < ActiveRecord::Migration
  def self.up
    create_table :daemon_statuses do |t|
      t.boolean :active
      t.timestamps
    end
  end

  def self.down
    drop_table :daemon_statuses
  end
end
