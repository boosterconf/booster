class MakeReviewTextAnActualTestColumn < ActiveRecord::Migration[4.2]
  def change
    change_column :reviews, :text, :text, limit: nil
  end

end
