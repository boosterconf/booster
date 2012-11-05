class ChangeDefaultNumParticipantsOnTalk < ActiveRecord::Migration
  def up
    change_column_default(:talks, :max_participants, nil)
  end

  def down
  end
end
