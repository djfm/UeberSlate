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

ActiveRecord::Schema.define(:version => 20121203201113) do

  create_table "chat_messages", :force => true do |t|
    t.integer  "chat_id"
    t.integer  "user_id"
    t.text     "message"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "chats", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.text     "topic"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "classifications", :force => true do |t|
    t.integer  "pack_id"
    t.string   "group"
    t.string   "category"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "classifications", ["pack_id", "category", "group"], :name => "index_classifications_on_pack_id_and_category_and_group"

  create_table "current_translations", :force => true do |t|
    t.integer  "pack_id"
    t.integer  "language_id"
    t.integer  "translation_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "message_id"
  end

  add_index "current_translations", ["pack_id", "message_id", "language_id", "translation_id"], :name => "all_fields_current_translations", :unique => true

  create_table "exports", :force => true do |t|
    t.integer  "pack_id"
    t.integer  "language_id"
    t.string   "url"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "functions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "language_id"
  end

  create_table "groupings", :force => true do |t|
    t.integer  "message_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "classification_id"
  end

  add_index "groupings", ["classification_id"], :name => "index_groupings_on_classification_id"

  create_table "languages", :force => true do |t|
    t.string   "code"
    t.string   "locale"
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "messages", :force => true do |t|
    t.string   "key"
    t.text     "string"
    t.integer  "language_id"
    t.string   "type"
    t.integer  "user_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "messages", ["key"], :name => "index_messages_on_key", :unique => true

  create_table "module_packs", :force => true do |t|
    t.string   "module_name"
    t.string   "project_id"
    t.string   "pack_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "archive_path"
  end

  create_table "packs", :force => true do |t|
    t.integer  "project_id"
    t.string   "name"
    t.text     "comment"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.boolean  "is_current"
  end

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.string   "version"
    t.text     "comment"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "role_white_lists", :force => true do |t|
    t.integer  "role_id"
    t.string   "action"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "controller"
    t.boolean  "any_language"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sources", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "statistics", :force => true do |t|
    t.integer  "pack_id"
    t.integer  "language_id"
    t.string   "category"
    t.integer  "total"
    t.integer  "translated"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "statistics", ["pack_id", "language_id", "category"], :name => "index_statistics_on_pack_id_and_language_id_and_category", :unique => true

  create_table "storages", :force => true do |t|
    t.integer  "pack_id"
    t.integer  "message_id"
    t.string   "storage_method"
    t.string   "storage_path"
    t.string   "storage_category"
    t.string   "storage_custom"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "storages", ["pack_id", "message_id"], :name => "index_storages_on_pack_id_and_message_id", :unique => true

  create_table "translations", :force => true do |t|
    t.string   "key"
    t.integer  "language_id"
    t.text     "string"
    t.integer  "user_id"
    t.integer  "reviewer_id"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.integer  "source_id"
    t.integer  "previous_translation_id"
  end

  add_index "translations", ["language_id"], :name => "index_translations_on_language_id"
  add_index "translations", ["reviewer_id"], :name => "index_translations_on_reviewer_id"
  add_index "translations", ["source_id", "language_id", "key", "reviewer_id", "user_id", "string"], :name => "all_fields"
  add_index "translations", ["user_id"], :name => "index_translations_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.datetime "last_seen"
    t.string   "channel"
    t.string   "last_translation_url"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
