class AddSpeakingHistoryToWorkshop < ActiveRecord::Migration
  def change
    add_column :talks, :speaking_history, :text
  end
end
