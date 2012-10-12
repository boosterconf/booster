class RemoveCommentColumnOnSponsors < ActiveRecord::Migration
  def up
    remove_column :sponsors, :comment
  end

  def down
  end
end
