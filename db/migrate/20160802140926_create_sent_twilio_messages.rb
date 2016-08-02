class CreateSentTwilioMessages < ActiveRecord::Migration
  def change
    create_table :sent_twilio_messages do |t|
      t.string :twilio_id
      t.integer :list_id
      t.string :to
      t.string :status
      t.string :error_code
      t.datetime :created_at
    end
  end
end
