class Order < ApplicationRecord
	has_many :tickets, dependent: :nullify
	after_initialize :default_values
	def default_values
		self.reference ||= SecureRandom.urlsafe_base64
	end
end
