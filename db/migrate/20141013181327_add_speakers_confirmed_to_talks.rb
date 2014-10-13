class AddSpeakersConfirmedToTalks < ActiveRecord::Migration
  def change
    add_column :talks, :speakers_confirmed, :boolean
  end
end
