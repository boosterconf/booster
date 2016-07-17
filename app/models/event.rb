class Event < ActiveRecord::Base
  belongs_to :user
  belongs_to :sponsor

  attr_accessible :user, :comment, :sponsor, :sponsor_id

  accepts_nested_attributes_for :sponsor

  default_scope { order('created_at desc') }
end