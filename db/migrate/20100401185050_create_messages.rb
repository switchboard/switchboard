class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.string :from
      t.string :to
      t.string :body
      t.string :origin
      t.string :origin_id
      t.integer :queue_id

      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
