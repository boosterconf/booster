class AddSpeakersDinnerToRegistrations < ActiveRecord::Migration
  def change
    add_column :registrations, :speakers_dinner, :boolean
  end
end
