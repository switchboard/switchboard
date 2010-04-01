class CreateMessageStates < ActiveRecord::Migration
  def self.up
    create_table :message_states do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :message_states
  end
end
