class AddTypeToPeriod < ActiveRecord::Migration[4.2]
  def change
    add_column :periods, :period_type, :string, default: 'workshop'
  end
end
