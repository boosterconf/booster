class ChangeDefaultNumParticipantsOnTalk < ActiveRecord::Migration[4.2]
  def up
    change_column_default(:talks, :max_participants, nil)
  end

  def down
  end
end
