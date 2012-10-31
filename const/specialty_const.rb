p '--- Reading Specialties const ---'

SPEC_1 	= 1
SPEC_2 	= 2
SPEC_3 	= 3
SPEC_4 	= 4
SPEC_5	= 5
SPEC_6	= 6
SPEC_7	= 7
SPEC_8	= 8

SPECIALTIES = {
	SPEC_1 => {:name => :waterlemon, 		:feed_point => 1800},
	SPEC_2 => {:name => :corn, 					:feed_point => 1800},
	SPEC_3 => {:name => :potato, 				:feed_point => 1800},
	SPEC_4 => {:name => :apple, 				:feed_point => 1800},
	SPEC_5 => {:name => :fish, 					:feed_point => 3600},
	SPEC_6 => {:name => :tiger, 				:feed_point => 3600},
	SPEC_7 => {:name => :mammuthus, 		:feed_point => 3600},
	SPEC_8 => {:name => :brachiosaurus, :feed_point => 3600}
}

SPECIALTY_TYPES = SPECIALTIES.keys
SPECIALTY_NAMES = SPECIALTIES.values.map{|v| v[:name]}