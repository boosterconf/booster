class AddHasslidesToTalks < ActiveRecord::Migration[5.2]
  def change
    add_column :talks, :hasSlides, :boolean, null: false, default: false
  end
end
