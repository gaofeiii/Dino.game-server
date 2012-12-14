# encoding: utf-8
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

book = Excelx.new("#{Rails.root}/const/dinosaurs.xlsx")

book.default_sheet = "dinosaurs_avai"

2.upto(10).each do |i|
	type = book.cell(i, 'A').to_i
	name = book.cell(i, 'C').to_sym
	cost = {:sun => 1}
	property = {:dinosaur_type => type}

	ITEMS[1][type] = {
		:type => 1,
		:name => name,
		:cost => cost,
		:property => property
	}
end

ITEMS.extend(ConstHelper::ItemsConstHelper)