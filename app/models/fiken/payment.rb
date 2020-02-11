module Fiken
	class Payment
        include Virtus.model
        include ActiveModel::Validations

        attribute :uuid, String
        attribute :date, DateTime
        attribute :account, String
        attribute :amount, Integer

        def to_hash
        	result = {
        		account: account,
        		amount: amount
        	}
        	result["uuid"] = uuid if(uuid)
        	result["date"] = date.strftime("%Y-%m-%d")
        	result
        end
	end
end