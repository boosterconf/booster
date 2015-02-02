class AddTypeToPeriod < ActiveRecord::Migration
  def change
    add_column :periods, :period_type, :string, default: 'workshop'
  end
end
