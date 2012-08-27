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
	SPEC_1 => {:name => :waterlemon},
	SPEC_2 => {:name => :corn},
	SPEC_3 => {:name => :potato},
	SPEC_4 => {:name => :apple},
	SPEC_5 => {:name => :fish},
	SPEC_6 => {:name => :tiger},
	SPEC_7 => {:name => :mammuthus},
	SPEC_8 => {:name => :brachiosaurus}
}

SPECIALTY_TYPES = SPECIALTIES.keys
SPECIALTY_NAMES = SPECIALTIES.values.map{|v| v[:name]}