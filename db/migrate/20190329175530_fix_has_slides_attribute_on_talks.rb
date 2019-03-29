class FixHasSlidesAttributeOnTalks < ActiveRecord::Migration[5.2]
  def change
    rename_column :talks, :hasSlides, :has_slides
  end
end
