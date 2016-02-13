class DropUnusedTables < ActiveRecord::Migration
  def up
    drop_table :daemon_statuses
    drop_table :gateways
    drop_table :message_states
    drop_table :db_files
    drop_table :phone_messages
    drop_table :phone_message_boxes
    drop_table :queues
    drop_table :phones
    drop_table :service_phone_numbers
  end

  def down

    create_table "service_phone_numbers", :force => true do |t|
      t.string   "phone_number"
      t.string   "service"
      t.datetime "created_at",   :null => false
      t.datetime "updated_at",   :null => false
    end

    create_table "phones", :force => true do |t|
      t.string   "number"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "queues", :force => true do |t|
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "phone_message_boxes", :force => true do |t|
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "phone_messages", :force => true do |t|
      t.string   "body"
      t.string   "from"
      t.string   "to"
      t.integer  "phone_message_box_id"
      t.integer  "phone_id"
      t.boolean  "read",                 :default => false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "db_files", :force => true do |t|
      t.binary "data"
    end

    create_table "gateways", :force => true do |t|
      t.string   "name"
      t.float    "cost_per_text"
      t.datetime "created_at",    :null => false
      t.datetime "updated_at",    :null => false
    end

    create_table "message_states", :force => true do |t|
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "daemon_statuses", :force => true do |t|
      t.boolean  "active"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
