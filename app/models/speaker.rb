class Speaker < ApplicationRecord
  acts_as_paranoid

  belongs_to :talk
  belongs_to :user
end
