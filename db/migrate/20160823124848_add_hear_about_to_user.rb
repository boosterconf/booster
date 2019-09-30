class AddHearAboutToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :hear_about, :string, default: ''
  end
end
