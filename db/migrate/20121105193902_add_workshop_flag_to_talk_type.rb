class AddWorkshopFlagToTalkType < ActiveRecord::Migration
  def change
    add_column :talk_types, :is_workshop, :boolean
  end
end
