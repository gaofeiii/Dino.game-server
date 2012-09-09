book = Excelx.new "#{Rails.root}/const/game_numerics/dinosaurs.xlsx"

DINOSAUR_GROWTH_FACTOR = 0.8..1.2

DINOSAUR_TYPES = {
	:scud => 1,
	:king => 2,
	:sentry => 3,
	:thorn => 4,
	:hammer => 5,
	:ripper => 6,
	:avenger => 7,
	:headache => 8,
	:vampire => 9,
	:tank => 10,
	:knight => 11,
	:thewhip => 12,
	:devil => 13,
	:earthquake => 14,
	:tyrant => 15
}


DINOSAURS = {}
book.default_sheet = 'dinosaurs'
2.upto(book.last_row).each do |i|
	type = book.cell(i, 'A').to_i
	name = book.cell(i, 'D').downcase
	hp = book.cell(i, 'E').to_i
	attack = book.cell(i, 'F').to_i
	defense = book.cell(i, 'G').to_i
	agility = book.cell(i, 'H').to_i
	hp_inc = book.cell(i, 'I').to_i
	attack_inc = book.cell(i, 'J').to_f
	defense_inc = book.cell(i, 'K').to_f
	agility_inc = book.cell(i, 'L').to_f
	hatching_time = book.cell(i, 'M').to_i
	unlock_level = book.cell(i, 'N').to_i
	mature_level = book.cell(i, 'O').to_i
	favor_food = book.cell(i, 'P').to_i
	hunger_time = book.cell(i,'Q').to_i
	DINOSAURS[type] = {
		:dinosaur_type => type,
		:property => {
			:hp => hp,
			:attack => attack,
			:defense => defense,
			:agility => agility,
			:hatching_time => hatching_time,
			:unlock_level => unlock_level,
			:mature_level => mature_level,
			:favor_food => favor_food,
			:hunger_time => hunger_time
		},
		:enhance_property => {
			:attack_inc => attack_inc,
			:defense_inc => defense_inc,
			:agility_inc => agility_inc,
			:hp_inc => hp_inc,
		}
	}
end


book.default_sheet = 'experience'

DINOSAUR_EXPS = {}

2.upto(book.last_row) do |i|
	level = book.cell(i, "A").to_i
	exp = book.cell(i, 'B').to_i
	DINOSAUR_EXPS[level] = exp
end

DINOSAURS.extend(ConstHelper::DinosaursConstHelper)























