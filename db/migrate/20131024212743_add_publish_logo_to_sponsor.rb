class AddPublishLogoToSponsor < ActiveRecord::Migration
  def change
    add_column :sponsors, :publish_logo, :boolean, default: false
  end
end
