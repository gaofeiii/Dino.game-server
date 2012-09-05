p "--- Reading items const ---"
require "#{Rails.root}/const/specialty_const.rb"

ITEM_TYPES = {
	:egg => 1,
	:specialty => 2,
}

ITEMS = {
	1 => {
		1 => {
			:type => 1,
			:name => :scud,
			:cost => {:sun => 1},
			:property => {:dinosaur_type => 1}
		}
	},

	2 => SPECIALTIES,
}


ITEMS.extend(ConstHelper::ItemsConstHelper)