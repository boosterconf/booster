class Review < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :reviewer, class_name: User
  belongs_to :talk

end
