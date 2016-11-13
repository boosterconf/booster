class Ticket < ActiveRecord::Base

  attr_accessible :name, :email, :company, :feedback, :gender, :roles, :attend_dinner, :dietary_info

  belongs_to :ticket_type

  default_scope  { order('tickets.created_at desc') }
end
