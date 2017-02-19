class Volunteer < ActiveRecord::Base
  attr_accessible :first_name,:last_name, :email, :phone_number
  has_and_belongs_to_many :volunteers, join_table: 'talks_volunteers'

  def full_name
    self.first_name + ' ' + self.last_name
  end

end
