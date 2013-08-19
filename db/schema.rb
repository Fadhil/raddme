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

ActiveRecord::Schema.define(:version => 20130819154040) do

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0, :null => false
    t.integer  "attempts",   :default => 0, :null => false
    t.text     "handler",                   :null => false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "friendships", :force => true do |t|
    t.integer "user_id"
    t.text    "friend_ids"
  end

  create_table "users", :force => true do |t|
    t.string   "encrypted_password",  :limit => 128, :default => "",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "fullname"
    t.string   "street"
    t.string   "locality"
    t.string   "country"
    t.string   "postalcode"
    t.string   "phone_mobile"
    t.string   "phone_work"
    t.string   "phone_fax"
    t.string   "title"
    t.string   "organization"
    t.string   "invite_token"
    t.string   "url"
    t.string   "slug"
    t.text     "custom_message"
    t.boolean  "is_company",                         :default => false
    t.string   "unique_friend_token"
    t.string   "email"
  end

  add_index "users", ["slug"], :name => "index_users_on_slug", :unique => true
  add_index "users", ["unique_friend_token"], :name => "index_users_on_unique_friend_token", :unique => true

end
