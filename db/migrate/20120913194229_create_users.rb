class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email,                          :null => false
      t.string :crypted_password,               :null => false
      t.string :password_salt,                  :null => false
      t.string :persistence_token,              :null => false
      t.string :name
      t.string :company
      t.string :phone_number
      t.text :description
      t.integer :login_count,                   :default => 0,     :null => false
      t.integer :failed_login_count,            :default => 0,     :null => false
      t.datetime :last_request_at
      t.datetime :current_login_at
      t.datetime :last_login_at
      t.string :current_login_ip
      t.boolean :is_admin
      t.string :perishable_token
      t.string :registration_ip
      t.boolean :accepted_privacy_guidelines
      t.boolean :accept_optional_email
      t.string :hometown
      t.string :role
      t.boolean :female
      t.integer :birthyear
      t.boolean :member_dnd
      t.boolean :featured_speaker,          :default => false
      t.boolean :feature_as_organizer,      :default => false
      t.boolean :invited,                   :default => false
      t.string :dietary_requirements

      t.timestamps
    end
  end
end
