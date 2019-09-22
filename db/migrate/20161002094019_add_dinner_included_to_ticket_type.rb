class AddDinnerIncludedToTicketType < ActiveRecord::Migration[4.2]
  def change
    add_column :ticket_types, :dinner_included, :boolean, default: true
  end
end
