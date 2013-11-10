class AddRolesToTalk < ActiveRecord::Migration
  def change
    add_column :talks, :appropriate_for_roles, :string
  end
end
