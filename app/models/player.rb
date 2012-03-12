class Player < Ohm::Model
	attribute :nickname
	attribute :village_id
	
	index :nickname
	index :village_id

	def village
		Village[village_id]
	end

end
