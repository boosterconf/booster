module Fiken
	def self.get_current
		if(@client)
			return @client
		end
		api = Hyperclient.new(Rails.application.secrets.fiken[:company_href]) do |client|
		  client.basic_auth(Rails.application.secrets.fiken[:username], Rails.application.secrets.fiken[:password])
		end
		@client = Fiken::Company.new(api.to_hash, api)
		@client
	end
end