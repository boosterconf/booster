class MoveSponsorCommentsIntoCommentsTable < ActiveRecord::Migration[4.2]
  def change
    Sponsor.all.each { |sponsor|
      unless sponsor.comment.empty?
        event = Event.new(:comment => sponsor.comment, :sponsor => sponsor, :created_at => '2012-01-01')
        event.save
      end
    }

  end
end
