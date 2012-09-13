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

ActiveRecord::Schema.define(:version => 20120913201622) do

  create_table "sponsors", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.integer  "user_id"
    t.date     "invoiced"
    t.date     "paid"
    t.string   "comment"
    t.string   "contact_person"
    t.string   "status"
    t.string   "contact_person_phone"
    t.string   "location"
    t.boolean  "was_sponsor_last_year"
    t.datetime "last_contacted_at"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                          :null => false
    t.string   "crypted_password",                               :null => false
    t.string   "password_salt",                                  :null => false
    t.string   "persistence_token",                              :null => false
    t.string   "name"
    t.string   "company"
    t.string   "phone_number"
    t.text     "description"
    t.integer  "login_count",                 :default => 0,     :null => false
    t.integer  "failed_login_count",          :default => 0,     :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.boolean  "is_admin"
    t.string   "perishable_token"
    t.string   "registration_ip"
    t.boolean  "accepted_privacy_guidelines"
    t.boolean  "accept_optional_email"
    t.string   "hometown"
    t.string   "role"
    t.boolean  "female"
    t.integer  "birthyear"
    t.boolean  "member_dnd"
    t.boolean  "featured_speaker",            :default => false
    t.boolean  "feature_as_organizer",        :default => false
    t.boolean  "invited",                     :default => false
    t.string   "dietary_requirements"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.string   "last_login_ip"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
