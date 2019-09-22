class FixShortTalksWithWrongType < ActiveRecord::Migration[4.2]
  def up

    Talk.includes(:talk_type).where(talk_types: { name: "Short talk" }).each do |talk|
      talk.type = "ShortTalk"
      talk.save!
    end
  end

  def down
  end
end
