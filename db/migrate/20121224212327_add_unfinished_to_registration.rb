class AddUnfinishedToRegistration < ActiveRecord::Migration
  def change
    add_column :registrations, :unfinished, :boolean
  end
end
