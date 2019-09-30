class AddSpeakersConfirmedToTalks < ActiveRecord::Migration[4.2]
  def change
    add_column :talks, :speakers_confirmed, :boolean
  end
end
