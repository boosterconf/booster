class AddSpeakingHistoryToWorkshop < ActiveRecord::Migration[4.2]
  def change
    add_column :talks, :speaking_history, :text
  end
end
