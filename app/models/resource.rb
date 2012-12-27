class Resource
	WOOD = 1
	STONE = 2
	GOLD_COIN = 3
	GEM = 4

	TYPE = {
		:wood => WOOD, 
		:stone => STONE,
		:gold_coin => GOLD_COIN,
		:gem => GEM
	}

	def self.types
		TYPE
	end
end