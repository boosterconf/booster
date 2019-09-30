class AddWorkshopFlagToTalkType < ActiveRecord::Migration[4.2]
  def change
    add_column :talk_types, :is_workshop, :boolean
  end
end
