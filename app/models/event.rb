class Event < ActiveRecord::Base

  belongs_to :user
  belongs_to :sponsor

  accepts_nested_attributes_for :sponsor

  default_scope { order('created_at desc') }
end