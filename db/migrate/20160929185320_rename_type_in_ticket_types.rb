class RenameTypeInTicketTypes < ActiveRecord::Migration
  def change
    change_table :ticket_types do |t|
      t.rename :type, :reference
    end
  end
end
