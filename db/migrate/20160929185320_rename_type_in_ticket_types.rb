class RenameTypeInTicketTypes < ActiveRecord::Migration[4.2]
  def change
    change_table :ticket_types do |t|
      t.rename :type, :reference
    end
  end
end
