class AddSponsorEvents < ActiveRecord::Migration[4.2]
  def change

    create_table :events do |t|
      t.text :comment
      t.references :sponsor
      t.references :user

      t.timestamps
    end

  end
end
