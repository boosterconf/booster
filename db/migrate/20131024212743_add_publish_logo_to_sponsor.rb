class AddPublishLogoToSponsor < ActiveRecord::Migration[4.2]
  def change
    add_column :sponsors, :publish_logo, :boolean, default: false
  end
end
