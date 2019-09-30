class AddAttachmentLogoToSponsors < ActiveRecord::Migration[4.2]
  def self.up
      add_attachment :sponsors, :logo
  end

  def self.down
    drop_attached_file :sponsors, :logo
  end
end
