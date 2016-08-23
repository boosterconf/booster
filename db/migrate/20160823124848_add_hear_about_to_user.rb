class AddHearAboutToUser < ActiveRecord::Migration
  def change
    add_column :users, :hear_about, :string, default: ''
  end
end
