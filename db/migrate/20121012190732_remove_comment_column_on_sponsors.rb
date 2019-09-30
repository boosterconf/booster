class RemoveCommentColumnOnSponsors < ActiveRecord::Migration[4.2]
  def up
    remove_column :sponsors, :comment
  end

  def down
  end
end
