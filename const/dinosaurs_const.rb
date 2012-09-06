book = Excelx.new "#{Rails.root}/const/game_numerics/dinosaurs.xlsx"

DINOSAUR_GROWTH_FACTOR = 0.8..1.2

DINOSAUR_TYPES = {
	:scud => 1
}

DINOSAURS = {
	1 => {
		:dinosaur_type => 1,
		:property => {
			:hp => 20,
			:attack => 12,
			:defense => 6,
			:agility => 20,
			:hatching_time => 3600,
			:player_level => 1,
			:mature_level => 3,
			:favor_food => 1,
			:hunger_time => 3600
		},
		:enhance_property => {
			:attack_inc => 2.2,
			:defense_inc => 1.6,
			:agility_inc => 3.0,
			:hp_inc => 3.0,
		}
	}
}


book.default_sheet = 'experience'

DINOSAUR_EXPS = {}

2.upto(book.last_row) do |i|
	level = book.cell(i, "A").to_i
	exp = book.cell(i, 'B').to_i
	DINOSAUR_EXPS[level] = exp
end

DINOSAURS.extend(ConstHelper::DinosaursConstHelper)