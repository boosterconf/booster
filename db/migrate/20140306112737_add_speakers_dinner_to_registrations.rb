class AddSpeakersDinnerToRegistrations < ActiveRecord::Migration[4.2]
  def change
    add_column :registrations, :speakers_dinner, :boolean
  end
end
