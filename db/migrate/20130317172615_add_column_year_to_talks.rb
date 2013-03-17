class AddColumnYearToTalks < ActiveRecord::Migration
  def change
    add_column :talks, :year, :integer
  end
end
