module Fiken
	def self.get_current
		@client ||= Fiken::Company.new(Agaon::Client.new(Rails.application.secrets.fiken[:username], Rails.application.secrets.fiken[:password], Rails.application.secrets.fiken[:company_href]))
		@client
	end
end