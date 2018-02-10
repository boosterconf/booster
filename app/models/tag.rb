class Tag < ApplicationRecord
  
  has_and_belongs_to_many :talks
  validates_presence_of :title
  validates_uniqueness_of :title, :case_sensitive => false

  def self.create_and_return_tags(tagnames)
    tags = []

    all_tags = Hash[Tag.all.map {|tag|  [tag.title.downcase, tag]}]

    tagnames.each { |title|
      tag = all_tags[title.downcase]

      if tag == nil
        tag = Tag.new({:title => title})
        tag.save!
      end
      tags.push(tag)
    }
    return tags
  end

end