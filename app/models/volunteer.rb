class Volunteer < ApplicationRecord

  has_and_belongs_to_many :volunteers, join_table: 'talks_volunteers'

  def full_name
    self.first_name + ' ' + self.last_name
  end

end
