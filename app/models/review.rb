class Review < ApplicationRecord

  belongs_to :reviewer, class_name: User
  belongs_to :talk

end
