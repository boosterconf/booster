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

ActiveRecord::Schema.define(:version => 20150129082313) do

  create_table "bios", :force => true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "bio"
    t.string   "twitter_handle"
    t.string   "blog"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "picture_updated_at"
  end

  create_table "comments", :force => true do |t|
    t.integer  "talk_id"
    t.integer  "user_id"
    t.string   "title"
    t.text     "description"
    t.boolean  "is_displayed"
    t.boolean  "is_a_review"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.text     "comment"
    t.integer  "sponsor_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "feedback_comments", :force => true do |t|
    t.integer "talk_id"
    t.string  "comment"
  end

  create_table "feedback_votes", :force => true do |t|
    t.integer "talk_id"
    t.integer "feedback_id"
    t.string  "comment"
    t.integer "vote"
  end

  create_table "feedbacks", :force => true do |t|
    t.string   "comment"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "invitees", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "phone_number"
    t.integer  "user_id"
    t.string   "status"
    t.string   "areas_of_expertise"
    t.string   "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "departs_at"
    t.datetime "arrives_at"
  end

  create_table "invoices", :force => true do |t|
    t.string   "our_reference"
    t.string   "your_reference"
    t.string   "recipient_name"
    t.string   "adress"
    t.string   "zip"
    t.string   "city"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.string   "email"
    t.string   "country"
    t.string   "status",         :default => "not_invoiced"
    t.datetime "invoiced_at"
    t.datetime "paid_at"
  end

  create_table "participants", :force => true do |t|
    t.integer  "talk_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "payment_notifications", :force => true do |t|
    t.text     "params"
    t.integer  "registration_id"
    t.string   "status"
    t.string   "transaction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "paid_amount"
    t.string   "currency"
    t.string   "registered_by"
  end

  create_table "periods", :force => true do |t|
    t.time     "start_time"
    t.time     "end_time"
    t.date     "day"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "registrations", :force => true do |t|
    t.integer  "user_id"
    t.text     "comments"
    t.decimal  "price"
    t.date     "invoiced_at"
    t.date     "paid_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_earlybird"
    t.boolean  "includes_dinner"
    t.string   "description"
    t.text     "ticket_type_old"
    t.text     "payment_notification_params"
    t.datetime "payment_complete_at"
    t.decimal  "paid_amount"
    t.text     "payment_reference"
    t.boolean  "registration_complete",       :default => false
    t.boolean  "manual_payment"
    t.text     "invoice_address"
    t.text     "invoice_description"
    t.boolean  "free_ticket",                 :default => false
    t.string   "completed_by"
    t.boolean  "invoiced",                    :default => false
    t.boolean  "unfinished"
    t.string   "unique_reference"
    t.integer  "invoice_id"
    t.boolean  "speakers_dinner"
  end

  create_table "reviews", :force => true do |t|
    t.integer  "talk_id"
    t.integer  "reviewer_id"
    t.string   "subject"
    t.text     "text"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "rooms", :force => true do |t|
    t.string   "name"
    t.integer  "capacity"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "slots", :force => true do |t|
    t.integer  "period_id"
    t.integer  "talk_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "room_id"
  end

  create_table "speakers", :force => true do |t|
    t.integer "talk_id"
    t.integer "user_id"
  end

  create_table "sponsors", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.date     "invoiced"
    t.date     "paid"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.string   "contact_person_phone_number"
    t.string   "location"
    t.boolean  "was_sponsor_last_year"
    t.datetime "last_contacted_at"
    t.string   "contact_person_first_name"
    t.string   "contact_person_last_name"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.boolean  "publish_logo",                :default => false
    t.string   "website"
  end

  create_table "tags", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags_talks", :id => false, :force => true do |t|
    t.integer "talk_id"
    t.integer "tag_id"
  end

  create_table "talk_feedbacks", :force => true do |t|
    t.integer  "talk_id"
    t.integer  "num_start"
    t.integer  "num_end"
    t.integer  "num_green"
    t.integer  "num_yellow"
    t.integer  "num_red"
    t.text     "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "talk_types", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "duration"
    t.boolean  "eligible_for_cfp"
    t.boolean  "eligible_for_free_ticket"
    t.boolean  "is_workshop"
  end

  create_table "talks", :force => true do |t|
    t.integer  "topic_id"
    t.string   "title"
    t.text     "description"
    t.boolean  "presenting_naked"
    t.string   "video_url"
    t.integer  "position"
    t.boolean  "submitted"
    t.string   "audience_level"
    t.integer  "votes_count",              :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "allow_commercial_use"
    t.string   "allow_derivatives"
    t.string   "slide_file_name"
    t.string   "slide_content_type"
    t.integer  "slide_file_size"
    t.datetime "slide_updated_at"
    t.integer  "period_id"
    t.integer  "comments_count"
    t.string   "acceptance_status",        :default => "pending"
    t.boolean  "email_sent",               :default => false
    t.integer  "sum_of_votes"
    t.integer  "num_of_votes"
    t.integer  "talk_type_id"
    t.integer  "max_participants"
    t.integer  "participants_count",       :default => 0
    t.string   "language"
    t.text     "participant_requirements"
    t.text     "equipment"
    t.string   "room_setup"
    t.integer  "year"
    t.text     "outline"
    t.string   "appropriate_for_roles"
    t.string   "type"
    t.boolean  "speakers_confirmed"
    t.text     "speaking_history"
  end

  create_table "ticket_types", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.text     "description"
    t.decimal  "price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "timeslots", :force => true do |t|
    t.string   "location"
    t.string   "day"
    t.string   "time"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "talk_id"
  end

  create_table "topics", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "login_count",                 :default => 0,     :null => false
    t.integer  "failed_login_count",          :default => 0,     :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
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
    t.string   "roles"
    t.string   "city"
    t.string   "zip"
    t.string   "gender"
    t.string   "first_name"
    t.string   "last_name"
  end

  create_table "votes", :force => true do |t|
    t.integer  "talk_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
