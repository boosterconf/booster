class AddRolesToTalk < ActiveRecord::Migration[4.2]
  def change
    add_column :talks, :appropriate_for_roles, :string
  end
end
