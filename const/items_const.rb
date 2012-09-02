ITEM_TYPES = {
	:egg => 1
}

ITEMS = {
	1 => {
		1 => {
			:type => 1,
			:name => :scud,
			:cost => {:sun => 1},
			:property => {:dinosaur_type => 1}
		}
	}
}


ITEMS.extend(ConstHelper::ItemsConstHelper)