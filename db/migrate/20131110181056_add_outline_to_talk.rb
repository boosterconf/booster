class AddOutlineToTalk < ActiveRecord::Migration
  def change
    add_column :talks, :outline, :text
  end
end
