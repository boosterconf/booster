class SetPendingAsDefaultvalueOnTalksAcceptanceStatus < ActiveRecord::Migration[4.2]
  def up
    change_column :talks, :acceptance_status, :string, :default => "pending"

    Talk.all.each { |talk|
      if talk.acceptance_status == nil
        talk.acceptance_status = "pending"
        talk.save!
      end
    }
  end

  def down
  end
end