class Review < ActiveRecord::Base

  attr_accessible :subject, :text

  belongs_to :reviewer, class_name: User
  belongs_to :talk

end
