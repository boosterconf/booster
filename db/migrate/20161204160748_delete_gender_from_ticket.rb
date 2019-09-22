class DeleteGenderFromTicket < ActiveRecord::Migration[4.2]
  def change
    remove_column :tickets, :gender
  end
end
