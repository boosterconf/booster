class FixShortTalksWithWrongType < ActiveRecord::Migration
  def up

    short_talk_type = TalkType.where(name: "Short talk").first

    Talk.includes(:talk_type).where(talk_types: { name: "Short talk" }).each do |talk|
      talk.talk_type = short_talk_type
      talk.save!
    end
  end

  def down
  end
end
