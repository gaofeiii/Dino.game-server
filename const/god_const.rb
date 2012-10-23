GODS_TYPES = {
	:argriculture => 1, # 农业之神
	:business			=> 2, # 战争之神
	:war		  		=> 3, # 商业之神
	:intelligence => 4 	# 智力之神
}


GODS = {
	1 => {
		:name => :god_of_argriculture,
		:property => {
			:wood_inc => 0.1,
			:wood_inc_step => 0.05,
			:stone_inc => 0.1,
			:stone_inc_step => 0.05
		}
	},
	2 => {
		:name => :god_of_business,
	},
	3 => {
		:name => :god_of_war,
	},
	4 => {
		:name => :god_of_intelligence,
	},
}