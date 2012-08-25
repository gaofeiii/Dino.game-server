# encoding: utf-8
p '--- Reading technologies const ---'
TECH_HOUSING 		= 1	# 住宅
TECH_LUMBERING 	= 2 # 伐木技术
TECH_QUARRYING 	= 3	# 采石技术
TECH_HUNTING 		= 4 # 狩猎技术
TECH_COLLECTING	= 5 # 采集技术
TECH_STORING 		= 6 # 储藏技术
TECH_HATCHING		= 7 # 孵化技术
TECH_TRAINING		= 8 # 驯养技术
TECH_BUSINESS 	= 9 # 商业技术
TECH_SCIENCE 		= 10# 科研技术
TECH_PRAYING		= 11 # 祭祀技术
TECH_ALCHEMY 		= 12 # 炼金
TECH_COURAGE 		= 13 # 勇气
TECH_FORTITUDE 	= 14 # 刚毅
TECH_LOYALTY 		= 15 # 忠诚
TECH_KINDHEARTED = 16 # 仁义
TECH_TREASURE 	= 17 # 寻宝
TECH_VIOLENCE 	= 18 # 残暴
TECH_PLUNDER 		= 19 # 掠夺
TECH_WISDOM 		= 20 # 智慧

TECHNOLOGIES = {}

TECHNOLOGIES_names = %w(
	tech_housing
	tech_lumbering
	TECH_QUARRYING 	
	tech_hunting 		
	tech_collecting	
	tech_storing 		
	tech_hatching		
	tech_training		
	tech_business 	
	tech_science 		
	tech_praying		
	tech_alchemy 		
	tech_courage 		
	tech_fortitude 	
	tech_loyalty 		
	tech_kindhearted
	tech_treasure 	
	tech_violence
	tech_plunder
	tech_wisdom
).each do |name|
	TECHNOLOGIES[name.upcase.constantize] = {:name => name}
end

book = Excelx.new "#{Rails.root}/const/game_numerics/technologies.xlsx"

book.default_sheet = '住宅'
3.upto(book.last_row).each do |i|
	level = book.cell(i, 'A').to_i

	condition = {:player_level => book.cell(i, 'K').to_i}

	cost = {
		:wood => book.cell(i, 'D').to_i,
		:stone => book.cell(i, 'E').to_i,
		:gold => book.cell(i, 'F').to_i,
		:population => book.cell(i, 'G').to_i,
		:time => book.cell(i, 'H').to_i,
	}

	property = {
		:population_inc => book.cell(i, 'B').to_i,
		:population_max => book.cell(i, 'C').to_i,
	}

	reward = {
		:experience => book.cell(i, 'H').to_i,
		:score => book.cell(i, 'I').to_i,
	}

	TECHNOLOGIES[TECH_HOUSING][level] ||= {}
	TECHNOLOGIES[TECH_HOUSING][level] = {
		:condition => condition,
		:cost => cost, 
		:property => property,
		:reward => reward
	}
end

book.default_sheet = '伐木技术'
3.upto(book.last_row).each do |i|
	level = book.cell(i, 'A').to_i
	condition = {:player_level => book.cell(i, 'j').to_i}
	cost = {
		:wood => book.cell(i, 'C').to_i,
		:stone => book.cell(i, 'D').to_i,
		:gold => book.cell(i, 'E').to_i,
		:time => book.cell(i, 'G').to_i,
		:population => book.cell(i, 'F').to_i
	}
	property = {
		:wood_inc => book.cell(i, 'B').to_i,
	}
	reward = {
		:experience => book.cell(i, 'h').to_i,
		:score => book.cell(i, 'i').to_i,
	}
	TECHNOLOGIES[TECH_LUMBERING][level] ||= {}
	TECHNOLOGIES[TECH_LUMBERING][level] = {
		:condition => condition,
		:cost => cost, 
		:property => property,
		:reward => reward
	}
end

book.default_sheet = '采石技术'
3.upto(book.last_row).each do |i|
	level = book.cell(i, 'A').to_i
	condition = {:player_level => book.cell(i, 'j').to_i}
	cost = {
		:wood => book.cell(i, 'C').to_i,
		:stone => book.cell(i, 'D').to_i,
		:gold => book.cell(i, 'E').to_i,
		:population => book.cell(i, 'F').to_i,
		:time => book.cell(i, 'G').to_i,
	}
	property = {
		:stone_inc => book.cell(i, 'B').to_i,
	}
	reward = {
		:experience => book.cell(i, 'H').to_i,
		:score => book.cell(i, 'i').to_i,
	}
	TECHNOLOGIES[TECH_QUARRYING][level] ||= {}
	TECHNOLOGIES[TECH_QUARRYING][level] = {
		:condition => condition,
		:cost => cost, 
		:property => property,
		:reward => reward
	}
end

book.default_sheet = '狩猎技术'
3.upto(book.last_row).each do |i|
	level = book.cell(i, 'A').to_i
	condition = {:player_level => book.cell(i, 'j').to_i}
	cost = {
		:wood => book.cell(i, 'C').to_i,
		:stone => book.cell(i, 'D').to_i,
		:gold => book.cell(i, 'E').to_i,
		:population => book.cell(i, 'F').to_i,
		:time => book.cell(i, 'G').to_i,
	}
	property = {
		:meat_inc => book.cell(i, 'B').to_i,
	}
	reward = {
		:experience => book.cell(i, 'H').to_i,
		:score => book.cell(i, 'i').to_i,
	}
	TECHNOLOGIES[TECH_HUNTING][level] ||= {}
	TECHNOLOGIES[TECH_HUNTING][level] = {
		:condition => condition,
		:cost => cost, 
		:property => property,
		:reward => reward
	}
end

book.default_sheet = '采集技术'
3.upto(book.last_row).each do |i|
	level = book.cell(i, 'A').to_i
	condition = {:player_level => book.cell(i, 'j').to_i}
	cost = {
		:wood => book.cell(i, 'C').to_i,
		:stone => book.cell(i, 'D').to_i,
		:gold => book.cell(i, 'E').to_i,
		:population => book.cell(i, 'F').to_i,
		:time => book.cell(i, 'G').to_i,
	}
	property = {
		:fruit_inc => book.cell(i, 'B').to_i,
	}
	reward = {
		:experience => book.cell(i, 'H').to_i,
		:score => book.cell(i, 'i').to_i,
	}
	TECHNOLOGIES[TECH_COLLECTING][level] ||= {}
	TECHNOLOGIES[TECH_COLLECTING][level] = {
		:condition => condition,
		:cost => cost, 
		:property => property,
		:reward => reward
	}
end

book.default_sheet = '储藏技术'
3.upto(book.last_row).each do |i|
	level = book.cell(i, 'A').to_i
	condition = {:player_level => book.cell(i, 'j').to_i}
	cost = {
		:wood => book.cell(i, 'C').to_i,
		:stone => book.cell(i, 'D').to_i,
		:gold => book.cell(i, 'E').to_i,
		:population => book.cell(i, 'F').to_i,
		:time => book.cell(i, 'G').to_i,
	}
	property = {
		:resource_max => book.cell(i, 'B').to_i,
	}
	reward = {
		:experience => book.cell(i, 'H').to_i,
		:score => book.cell(i, 'i').to_i,
	}
	TECHNOLOGIES[TECH_STORING][level] ||= {}
	TECHNOLOGIES[TECH_STORING][level] = {
		:condition => condition,
		:cost => cost, 
		:property => property,
		:reward => reward
	}
end

book.default_sheet = '孵化技术'
3.upto(book.last_row).each do |i|
	level = book.cell(i, 'A').to_i
	condition = {:player_level => book.cell(i, 'l').to_i}
	cost = {
		:wood => book.cell(i, 'e').to_i,
		:stone => book.cell(i, 'f').to_i,
		:gold => book.cell(i, 'g').to_i,
		:population => book.cell(i, 'h').to_i,
		:time => book.cell(i, 'i').to_i,
	}
	property = {
		:eggs_max => book.cell(i, 'B').to_i,
		:hatch_max => book.cell(i, 'C').to_i,
		:hatch_efficiency => book.cell(i, 'd').to_i
	}
	reward = {
		:experience => book.cell(i, 'j').to_i,
		:score => book.cell(i, 'k').to_i,
	}
	TECHNOLOGIES[TECH_HATCHING][level] ||= {}
	TECHNOLOGIES[TECH_HATCHING][level] = {
		:condition => condition,
		:cost => cost, 
		:property => property,
		:reward => reward
	}
end

book.default_sheet = '驯养技术'
3.upto(book.last_row).each do |i|
	level = book.cell(i, 'A').to_i
	condition = {:player_level => book.cell(i, 'k').to_i}
	cost = {
		:wood => book.cell(i, 'd').to_i,
		:stone => book.cell(i, 'e').to_i,
		:gold => book.cell(i, 'f').to_i,
		:population => book.cell(i, 'g').to_i,
		:time => book.cell(i, 'h').to_i,
	}
	property = {
		:dinosaur_max => book.cell(i, 'B').to_i,
		:training_max => book.cell(i, 'C').to_i
	}
	reward = {
		:experience => book.cell(i, 'i').to_i,
		:score => book.cell(i, 'j').to_i,
	}
	TECHNOLOGIES[TECH_TRAINING][level] ||= {}
	TECHNOLOGIES[TECH_TRAINING][level] = {
		:condition => condition,
		:cost => cost, 
		:property => property,
		:reward => reward
	}
end

book.default_sheet = '商业技术'
3.upto(book.last_row).each do |i|
	level = book.cell(i, 'A').to_i
	condition = {:player_level => book.cell(i, 'k').to_i}
	cost = {
		:wood => book.cell(i, 'd').to_i,
		:stone => book.cell(i, 'e').to_i,
		:gold => book.cell(i, 'f').to_i,
		:population => book.cell(i, 'g').to_i,
		:time => book.cell(i, 'h').to_i,
	}
	property = {
		:transport_effeciency => book.cell(i, 'B').to_f,
		:tax => book.cell(i, 'C').to_f
	}
	reward = {
		:experience => book.cell(i, 'i').to_i,
		:score => book.cell(i, 'j').to_i,
	}
	TECHNOLOGIES[TECH_BUSINESS][level] ||= {}
	TECHNOLOGIES[TECH_BUSINESS][level] = {
		:condition => condition,
		:cost => cost, 
		:property => property,
		:reward => reward
	}
end

book.default_sheet = '科研技术'
3.upto(book.last_row).each do |i|
	level = book.cell(i, 'A').to_i
	condition = {:player_level => book.cell(i, 'j').to_i}
	cost = {
		:wood => book.cell(i, 'C').to_i,
		:stone => book.cell(i, 'D').to_i,
		:gold => book.cell(i, 'E').to_i,
		:population => book.cell(i, 'F').to_i,
		:time => book.cell(i, 'G').to_i,
	}
	property = {
		:research_effectiency => book.cell(i, 'B').to_f,
	}
	reward = {
		:experience => book.cell(i, 'H').to_i,
		:score => book.cell(i, 'i').to_i,
	}
	TECHNOLOGIES[TECH_SCIENCE][level] ||= {}
	TECHNOLOGIES[TECH_SCIENCE][level] = {
		:condition => condition,
		:cost => cost, 
		:property => property,
		:reward => reward
	}
end

book.default_sheet = '祭祀技术'
3.upto(book.last_row).each do |i|
	level = book.cell(i, 'A').to_i
	condition = {:player_level => book.cell(i, 'j').to_i}
	cost = {
		:wood => book.cell(i, 'C').to_i,
		:stone => book.cell(i, 'D').to_i,
		:gold => book.cell(i, 'E').to_i,
		:population => book.cell(i, 'F').to_i,
		:time => book.cell(i, 'G').to_i,
	}
	property = {
		:pray_effectiency => book.cell(i, 'B').to_f,
	}
	reward = {
		:experience => book.cell(i, 'H').to_i,
		:score => book.cell(i, 'i').to_i,
	}
	TECHNOLOGIES[TECH_PRAYING][level] ||= {}
	TECHNOLOGIES[TECH_PRAYING][level] = {
		:condition => condition,
		:cost => cost, 
		:property => property,
		:reward => reward
	}
end


book.default_sheet = '炼金'
3.upto(book.last_row).each do |i|
	level = book.cell(i, 'A').to_i
	condition = {:player_level => book.cell(i, 'j').to_i}
	cost = {
		:wood => book.cell(i, 'C').to_i,
		:stone => book.cell(i, 'D').to_i,
		:gold => book.cell(i, 'E').to_i,
		:population => book.cell(i, 'F').to_i,
		:time => book.cell(i, 'G').to_i,
	}
	property = {
		:extra_gold => book.cell(i, 'B').to_f,
	}
	reward = {
		:experience => book.cell(i, 'H').to_i,
		:score => book.cell(i, 'i').to_i,
	}
	TECHNOLOGIES[TECH_ALCHEMY][level] ||= {}
	TECHNOLOGIES[TECH_ALCHEMY][level] = {
		:condition => condition,
		:cost => cost, 
		:property => property,
		:reward => reward
	}
end

book.default_sheet = '勇气'
3.upto(book.last_row).each do |i|
	level = book.cell(i, 'A').to_i
	condition = {:player_level => book.cell(i, 'j').to_i}
	cost = {
		:wood => book.cell(i, 'C').to_i,
		:stone => book.cell(i, 'D').to_i,
		:gold => book.cell(i, 'E').to_i,
		:population => book.cell(i, 'F').to_i,
		:time => book.cell(i, 'G').to_i,
	}
	property = {
		:attack_inc => book.cell(i, 'B').to_f,
	}
	reward = {
		:experience => book.cell(i, 'H').to_i,
		:score => book.cell(i, 'i').to_i,
	}
	TECHNOLOGIES[TECH_COURAGE][level] ||= {}
	TECHNOLOGIES[TECH_COURAGE][level] = {
		:condition => condition,
		:cost => cost, 
		:property => property,
		:reward => reward
	}
end

book.default_sheet = '刚毅'
3.upto(book.last_row).each do |i|
	level = book.cell(i, 'A').to_i
	condition = {:player_level => book.cell(i, 'j').to_i}
	cost = {
		:wood => book.cell(i, 'C').to_i,
		:stone => book.cell(i, 'D').to_i,
		:gold => book.cell(i, 'E').to_i,
		:population => book.cell(i, 'F').to_i,
		:time => book.cell(i, 'G').to_i,
	}
	property = {
		:defense_inc => book.cell(i, 'B').to_f,
	}
	reward = {
		:experience => book.cell(i, 'H').to_i,
		:score => book.cell(i, 'i').to_i,
	}
	TECHNOLOGIES[TECH_FORTITUDE][level] ||= {}
	TECHNOLOGIES[TECH_FORTITUDE][level] = {
		:condition => condition,
		:cost => cost, 
		:property => property,
		:reward => reward
	}
end

book.default_sheet = '忠诚'
3.upto(book.last_row).each do |i|
	level = book.cell(i, 'A').to_i
	condition = {:player_level => book.cell(i, 'j').to_i}
	cost = {
		:wood => book.cell(i, 'C').to_i,
		:stone => book.cell(i, 'D').to_i,
		:gold => book.cell(i, 'E').to_i,
		:population => book.cell(i, 'F').to_i,
		:time => book.cell(i, 'G').to_i,
	}
	property = {
		:hp_inc => book.cell(i, 'B').to_f,
	}
	reward = {
		:experience => book.cell(i, 'H').to_i,
		:score => book.cell(i, 'i').to_i,
	}
	TECHNOLOGIES[TECH_LOYALTY][level] ||= {}
	TECHNOLOGIES[TECH_LOYALTY][level] = {
		:condition => condition,
		:cost => cost, 
		:property => property,
		:reward => reward
	}
end

book.default_sheet = '仁义'
3.upto(book.last_row).each do |i|
	level = book.cell(i, 'A').to_i
	condition = {:player_level => book.cell(i, 'j').to_i}
	cost = {
		:wood => book.cell(i, 'C').to_i,
		:stone => book.cell(i, 'D').to_i,
		:gold => book.cell(i, 'E').to_i,
		:population => book.cell(i, 'F').to_i,
		:time => book.cell(i, 'G').to_i,
	}
	property = {
		:trigger_inc => book.cell(i, 'B').to_f,
	}
	reward = {
		:experience => book.cell(i, 'H').to_i,
		:score => book.cell(i, 'i').to_i,
	}
	TECHNOLOGIES[TECH_KINDHEARTED][level] ||= {}
	TECHNOLOGIES[TECH_KINDHEARTED][level] = {
		:condition => condition,
		:cost => cost, 
		:property => property,
		:reward => reward
	}
end

book.default_sheet = '寻宝'
3.upto(book.last_row).each do |i|
	level = book.cell(i, 'A').to_i
	condition = {:player_level => book.cell(i, 'j').to_i}
	cost = {
		:wood => book.cell(i, 'C').to_i,
		:stone => book.cell(i, 'D').to_i,
		:gold => book.cell(i, 'E').to_i,
		:population => book.cell(i, 'F').to_i,
		:time => book.cell(i, 'G').to_i,
	}
	property = {
		:eggfall => book.cell(i, 'B').to_f,
	}
	reward = {
		:experience => book.cell(i, 'H').to_i,
		:score => book.cell(i, 'i').to_i,
	}
	TECHNOLOGIES[TECH_TREASURE][level] ||= {}
	TECHNOLOGIES[TECH_TREASURE][level] = {
		:condition => condition,
		:cost => cost, 
		:property => property,
		:reward => reward
	}
end

book.default_sheet = '残暴'
3.upto(book.last_row).each do |i|
	level = book.cell(i, 'A').to_i
	condition = {:player_level => book.cell(i, 'j').to_i}
	cost = {
		:wood => book.cell(i, 'C').to_i,
		:stone => book.cell(i, 'D').to_i,
		:gold => book.cell(i, 'E').to_i,
		:population => book.cell(i, 'F').to_i,
		:time => book.cell(i, 'G').to_i,
	}
	property = {
		:damage_inc => book.cell(i, 'B').to_f,
	}
	reward = {
		:experience => book.cell(i, 'H').to_i,
		:score => book.cell(i, 'i').to_i,
	}
	TECHNOLOGIES[TECH_VIOLENCE][level] ||= {}
	TECHNOLOGIES[TECH_VIOLENCE][level] = {
		:condition => condition,
		:cost => cost, 
		:property => property,
		:reward => reward
	}
end

book.default_sheet = '掠夺'
3.upto(book.last_row).each do |i|
	level = book.cell(i, 'A').to_i
	condition = {:player_level => book.cell(i, 'j').to_i}
	cost = {
		:wood => book.cell(i, 'C').to_i,
		:stone => book.cell(i, 'D').to_i,
		:gold => book.cell(i, 'E').to_i,
		:population => book.cell(i, 'F').to_i,
		:time => book.cell(i, 'G').to_i,
	}
	property = {
		:plunder => book.cell(i, 'B').to_f,
	}
	reward = {
		:experience => book.cell(i, 'H').to_i,
		:score => book.cell(i, 'i').to_i,
	}
	TECHNOLOGIES[TECH_PLUNDER][level] ||= {}
	TECHNOLOGIES[TECH_PLUNDER][level] = {
		:condition => condition,
		:cost => cost, 
		:property => property,
		:reward => reward
	}
end

book.default_sheet = '智慧'
3.upto(book.last_row).each do |i|
	level = book.cell(i, 'A').to_i
	condition = {:player_level => book.cell(i, 'j').to_i}
	cost = {
		:wood => book.cell(i, 'C').to_i,
		:stone => book.cell(i, 'D').to_i,
		:gold => book.cell(i, 'E').to_i,
		:population => book.cell(i, 'F').to_i,
		:time => book.cell(i, 'G').to_i,
	}
	property = {
		:plunder => book.cell(i, 'B').to_f,
	}
	reward = {
		:experience => book.cell(i, 'H').to_i,
		:score => book.cell(i, 'i').to_i,
	}
	TECHNOLOGIES[TECH_WISDOM][level] ||= {}
	TECHNOLOGIES[TECH_WISDOM][level] = {
		:condition => condition,
		:cost => cost, 
		:property => property,
		:reward => reward
	}
end

TECHNOLOGIES.extend(ConstHelper::TechnologiesConstHelper)






















