# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120721170332) do

  create_table "attachments", :force => true do |t|
    t.integer "list_id"
    t.string  "content_type"
    t.string  "filename"
    t.string  "thumbnail"
    t.integer "size"
    t.integer "width"
    t.integer "height"
    t.integer "db_file_id"
  end

  create_table "daemon_statuses", :force => true do |t|
    t.boolean  "active"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
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

  create_table "list_memberships", :force => true do |t|
    t.integer  "list_id"
    t.integer  "phone_number_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "lists", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.string   "long_name"
    t.boolean  "allow_email_gateway",         :default => true
    t.boolean  "allow_commercial_gateway",    :default => true
    t.boolean  "prefer_email",                :default => true
    t.string   "incoming_phone_number"
    t.boolean  "use_incoming_keyword"
    t.boolean  "email_admin_with_response"
    t.boolean  "text_admin_with_response"
    t.boolean  "save_response_in_interface"
    t.boolean  "all_users_can_send_messages", :default => true
    t.boolean  "open_membership",             :default => true
    t.boolean  "moderated_membership"
    t.boolean  "use_welcome_message",         :default => false
    t.string   "custom_welcome_message"
    t.string   "incoming_number"
    t.boolean  "add_list_name_header"
    t.boolean  "identify_sender"
  end

  create_table "message_states", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "messages", :force => true do |t|
    t.string   "from"
    t.string   "to"
    t.string   "body"
    t.string   "origin"
    t.string   "origin_id"
    t.integer  "message_state_id"
    t.string   "type"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "list_id"
    t.integer  "sender_id"
    t.integer  "recipient_id"
  end

  create_table "phone_message_boxes", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "phone_messages", :force => true do |t|
    t.string   "body"
    t.string   "from"
    t.string   "to"
    t.integer  "phone_message_box_id"
    t.integer  "phone_id"
    t.boolean  "read",                 :default => false
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  create_table "phone_numbers", :force => true do |t|
    t.string   "number"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "user_id"
    t.string   "provider_email"
    t.string   "gateway_preference"
  end

  create_table "phones", :force => true do |t|
    t.string   "number"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "queues", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "service_phone_numbers", :force => true do |t|
    t.string   "phone_number"
    t.string   "service"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "survey_answers", :force => true do |t|
    t.integer  "survey_question_id"
    t.string   "response_text"
    t.integer  "phone_number_id"
    t.integer  "survey_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "survey_questions", :force => true do |t|
    t.integer  "question_type"
    t.integer  "survey_id"
    t.string   "name"
    t.string   "question_text"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "position"
  end

  create_table "survey_states", :force => true do |t|
    t.integer  "phone_number_id"
    t.integer  "survey_id"
    t.integer  "survey_question_id"
    t.boolean  "active"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.boolean  "finished",           :default => false
  end

  create_table "surveys", :force => true do |t|
    t.integer  "list_id"
    t.string   "name"
    t.text     "description"
    t.boolean  "active"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.string   "perishable_token"
    t.boolean  "admin",             :default => false
    t.string   "login"
  end

end
