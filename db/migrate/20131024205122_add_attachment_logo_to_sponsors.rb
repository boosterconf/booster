class AddAttachmentLogoToSponsors < ActiveRecord::Migration
  def self.up
      add_attachment :sponsors, :logo
  end

  def self.down
    drop_attached_file :sponsors, :logo
  end
end
