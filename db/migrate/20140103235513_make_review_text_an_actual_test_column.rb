class MakeReviewTextAnActualTestColumn < ActiveRecord::Migration
  def change
    change_column :reviews, :text, :text, limit: nil
  end

end
