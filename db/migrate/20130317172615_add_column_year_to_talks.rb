class AddColumnYearToTalks < ActiveRecord::Migration[4.2]
  def change
    add_column :talks, :year, :integer
  end
end
