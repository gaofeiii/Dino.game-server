class Resource
	WOOD = 1
	STONE = 2
	GOLD_COIN = 3
	GEM = 4

	TYPE = {
		:wood => WOOD,
		WOOD => :wood,
		:stone => STONE,
		STONE => :stone,
		:gold_coin => GOLD_COIN,
		GOLD_COIN => :gold_coin,
		:sun => GEM,
		GEM => :sun
	}

	def self.types
		TYPE
	end
end