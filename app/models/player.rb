class Player < GameClass
	attribute :account_id, Integer
	
	attribute :nickname, String
	attribute :village_id, Integer
	
	index :nickname
	index :village_id

	def village
		Village[village_id]
	end

end
