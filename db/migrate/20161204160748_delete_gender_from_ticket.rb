class DeleteGenderFromTicket < ActiveRecord::Migration
  def change
    remove_column :tickets, :gender
  end
end
