class AddDinnerIncludedToTicketType < ActiveRecord::Migration
  def change
    add_column :ticket_types, :dinner_included, :boolean, default: true
  end
end
