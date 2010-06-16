class AddSenderAndRecipientIdToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :sender_id, :int  ## user_id
    add_column :messages, :recipient_id, :int  ## user_id
  end

  def self.down
    remove_column :messages, :sender_id
    remove_column :messages, :recipient_id
  end
end
