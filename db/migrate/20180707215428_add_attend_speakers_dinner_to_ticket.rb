class AddAttendSpeakersDinnerToTicket < ActiveRecord::Migration[5.2]
  def change
    add_column :tickets, :attend_speakers_dinner, :bool
  end
end
