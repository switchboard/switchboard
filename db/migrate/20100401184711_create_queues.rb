class CreateQueues < ActiveRecord::Migration
  def self.up
    create_table :queues do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :queues
  end
end
