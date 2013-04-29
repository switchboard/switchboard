class AddMessageAasm < ActiveRecord::Migration
  # Preventing broken migrations
  class Message < ActiveRecord::Base
  end

  def up
    add_column :messages, :aasm_state, :string
    add_index :messages, [:aasm_state], name: 'index_messages_on_aasm_state'

    Message.reset_column_information
    Message.where(message_state_id: MessageState.find_by_name('outgoing')).update_all(aasm_state: 'old_outgoing')
    Message.where(message_state_id: MessageState.find_by_name('incoming')).update_all(aasm_state: 'incoming')
    Message.where(message_state_id: MessageState.find_by_name('handled')).update_all(aasm_state: 'sent')
    Message.where(message_state_id: MessageState.find_by_name('sent')).update_all(aasm_state: 'sent')
    Message.where(message_state_id: MessageState.find_by_name('error_incoming')).update_all(aasm_state: 'old_error_incoming')
    Message.where(message_state_id: MessageState.find_by_name('error_outgoing')).update_all(aasm_state: 'old_error_outgoing')
  end

  def down
    remove_column :messages, :aasm_state
    # index is automatically removed
  end
end