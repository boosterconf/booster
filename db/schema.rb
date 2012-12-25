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

ActiveRecord::Schema.define(:version => 20121224215444) do

  create_table "bios", :force => true do |t|
    t.integer   "user_id"
    t.string    "title"
    t.text      "bio"
    t.string    "twitter_handle"
    t.string    "blog"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "picture_file_name"
    t.string    "picture_content_type"
    t.integer   "picture_file_size"
    t.timestamp "picture_updated_at"
  end

  create_table "comments", :force => true do |t|
    t.integer   "talk_id"
    t.integer   "user_id"
    t.string    "title"
    t.text      "description"
    t.boolean   "is_displayed"
    t.boolean   "is_a_review"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "events", :force => true do |t|
    t.text      "comment"
    t.integer   "sponsor_id"
    t.integer   "user_id"
    t.timestamp "created_at", :null => false
    t.timestamp "updated_at", :null => false
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
    t.string    "day"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "invitees", :force => true do |t|
    t.string    "name"
    t.string    "email"
    t.string    "phone_number"
    t.integer   "user_id"
    t.string    "status"
    t.string    "areas_of_expertise"
    t.string    "notes"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.timestamp "departs_at"
    t.timestamp "arrives_at"
  end

  create_table "participants", :force => true do |t|
    t.integer   "talk_id"
    t.integer   "user_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "payment_notifications", :force => true do |t|
    t.text      "params"
    t.integer   "registration_id"
    t.string    "status"
    t.string    "transaction_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.decimal   "paid_amount"
    t.string    "currency"
    t.string    "registered_by"
  end

  create_table "periods", :force => true do |t|
    t.time      "start_time"
    t.time      "end_time"
    t.date      "day"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "registrations", :force => true do |t|
    t.integer   "user_id"
    t.text      "comments"
    t.decimal   "price"
    t.date      "invoiced_at"
    t.date      "paid_at"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.boolean   "is_earlybird"
    t.boolean   "includes_dinner"
    t.string    "description"
    t.text      "ticket_type_old"
    t.text      "payment_notification_params"
    t.timestamp "payment_complete_at"
    t.decimal   "paid_amount"
    t.text      "payment_reference"
    t.boolean   "registration_complete"
    t.boolean   "manual_payment"
    t.text      "invoice_address"
    t.text      "invoice_description"
    t.boolean   "free_ticket"
    t.string    "completed_by"
    t.boolean   "invoiced"
    t.boolean   "unfinished"
    t.string    "unique_reference"
  end

  create_table "slots", :force => true do |t|
    t.string    "room"
    t.integer   "period_id"
    t.integer   "talk_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "speakers", :force => true do |t|
    t.integer "talk_id"
    t.integer "user_id"
  end

  create_table "sponsors", :force => true do |t|
    t.string    "name"
    t.string    "email"
    t.date      "invoiced"
    t.date      "paid"
    t.integer   "user_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "status"
    t.string    "contact_person_phone_number"
    t.string    "location"
    t.boolean   "was_sponsor_last_year"
    t.timestamp "last_contacted_at"
    t.string    "contact_person_first_name"
    t.string    "contact_person_last_name"
  end

  create_table "tags", :force => true do |t|
    t.string    "title"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "tags_talks", :id => false, :force => true do |t|
    t.integer "talk_id"
    t.integer "tag_id"
  end

  create_table "talk_feedbacks", :force => true do |t|
    t.integer   "talk_id"
    t.integer   "num_start"
    t.integer   "num_end"
    t.integer   "num_green"
    t.integer   "num_yellow"
    t.integer   "num_red"
    t.text      "comments"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "talk_types", :force => true do |t|
    t.string    "name"
    t.string    "description"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "duration"
    t.boolean   "eligible_for_cfp"
    t.boolean   "eligible_for_free_ticket"
    t.boolean   "is_workshop"
  end

  create_table "talks", :force => true do |t|
    t.integer   "topic_id"
    t.string    "title"
    t.text      "description"
    t.boolean   "presenting_naked"
    t.string    "video_url"
    t.integer   "position"
    t.boolean   "submitted"
    t.string    "audience_level"
    t.integer   "votes_count",              :default => 0
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.boolean   "allow_commercial_use"
    t.string    "allow_derivatives"
    t.string    "slide_file_name"
    t.string    "slide_content_type"
    t.integer   "slide_file_size"
    t.timestamp "slide_updated_at"
    t.integer   "period_id"
    t.integer   "comments_count"
    t.string    "acceptance_status",        :default => "pending"
    t.boolean   "email_sent",               :default => false
    t.integer   "sum_of_votes"
    t.integer   "num_of_votes"
    t.integer   "talk_type_id"
    t.integer   "max_participants"
    t.integer   "participants_count",       :default => 0
    t.string    "language"
    t.text      "participant_requirements"
    t.text      "equipment"
    t.string    "room_setup"
  end

  create_table "ticket_types", :force => true do |t|
    t.string    "type"
    t.string    "name"
    t.text      "description"
    t.decimal   "price"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "topics", :force => true do |t|
    t.string    "title"
    t.text      "description"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string    "email",                                          :null => false
    t.string    "crypted_password",                               :null => false
    t.string    "password_salt",                                  :null => false
    t.string    "persistence_token",                              :null => false
    t.string    "name"
    t.string    "company"
    t.string    "phone_number"
    t.text      "description"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "login_count",                 :default => 0,     :null => false
    t.integer   "failed_login_count",          :default => 0,     :null => false
    t.timestamp "last_request_at"
    t.timestamp "current_login_at"
    t.timestamp "last_login_at"
    t.string    "current_login_ip"
    t.string    "last_login_ip"
    t.boolean   "is_admin"
    t.string    "perishable_token"
    t.string    "registration_ip"
    t.boolean   "accepted_privacy_guidelines"
    t.boolean   "accept_optional_email"
    t.string    "hometown"
    t.string    "role"
    t.boolean   "female"
    t.integer   "birthyear"
    t.boolean   "member_dnd"
    t.boolean   "featured_speaker",            :default => false
    t.boolean   "feature_as_organizer",        :default => false
    t.boolean   "invited",                     :default => false
    t.string    "dietary_requirements"
    t.string    "roles"
    t.string    "city"
    t.string    "zip"
    t.string    "gender"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

  create_table "votes", :force => true do |t|
    t.integer   "talk_id"
    t.integer   "user_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

end
