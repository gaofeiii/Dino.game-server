# # encoding: utf-8
# p '--- Reading technologies const ---'

# TECH_1		= 1		# 住宅
# TECH_2		= 2		# 伐木技术
# TECH_3		= 3		# 采石技术
# TECH_4		= 4		# 狩猎技术
# TECH_5		= 5		# 采集技术
# TECH_6		= 6		# 储藏技术
# TECH_7		= 7		# 孵化技术
# TECH_8		= 8		# 驯养技术
# TECH_9		= 9		# 商业技术
# TECH_10		= 10	# 科研技术
# TECH_11		= 11	# 祭祀技术
# TECH_12		= 12	# 炼金
# TECH_13		= 13	# 勇气
# TECH_14		= 14	# 刚毅
# TECH_15		= 15	# 忠诚
# TECH_16		= 16	# 仁义
# TECH_17		= 17	# 寻宝
# TECH_18		= 18	# 残暴
# TECH_19		= 19	# 掠夺
# TECH_20		= 20	# 智慧

# TECHNOLOGIES = {
# 	1		=> {:name => :housing},
# 	2		=> {:name => :lumbering},
# 	3		=> {:name => :quarrying},
# 	4		=> {:name => :hunting},
# 	5		=> {:name => :collecting},
# 	6		=> {:name => :storing},
# 	7		=> {:name => :hatching},
# 	8		=> {:name => :training},
# 	9		=> {:name => :business},
# 	10	=> {:name => :science},
# 	11	=> {:name => :praying},
# 	12	=> {:name => :alchemy},
# 	13	=> {:name => :courage},
# 	14	=> {:name => :fortitude},
# 	15	=> {:name => :loyalty},
# 	16	=> {:name => :kindhearted},
# 	17	=> {:name => :treasure},
# 	18	=> {:name => :violence},
# 	19	=> {:name => :plunder},
# 	20	=> {:name => :wisdom},
# }

# TECHNOLOGY_TYPES = TECHNOLOGIES.keys
# TECHNOLOGY_NAMES = TECHNOLOGIES.values.map{|v| v[:name]}

# book = Excelx.new "#{Rails.root}/const/game_numerics/technologies.xlsx"

# book.default_sheet = '住宅'
# 3.upto(book.last_row).each do |i|
# 	level = book.cell(i, 'A').to_i

# 	condition = {:player_level => book.cell(i, 'K').to_i}

# 	cost = {
# 		:wood => book.cell(i, 'D').to_i,
# 		:stone => book.cell(i, 'E').to_i,
# 		:gold => book.cell(i, 'F').to_i,
# 		:population => book.cell(i, 'G').to_i,
# 		:time => book.cell(i, 'H').to_i,
# 	}

# 	property = {
# 		:population_inc => book.cell(i, 'B').to_i,
# 		:population_max => book.cell(i, 'C').to_i,
# 	}

# 	reward = {
# 		:experience => book.cell(i, 'H').to_i,
# 		:score => book.cell(i, 'I').to_i,
# 	}

# 	TECHNOLOGIES[TECH_1][level] ||= {}
# 	TECHNOLOGIES[TECH_1][level] = {
# 		:condition => condition,
# 		:cost => cost, 
# 		:property => property,
# 		:reward => reward
# 	}
# end

# book.default_sheet = '伐木技术'
# 3.upto(book.last_row).each do |i|
# 	level = book.cell(i, 'A').to_i
# 	condition = {:player_level => book.cell(i, 'j').to_i}
# 	cost = {
# 		:wood => book.cell(i, 'C').to_i,
# 		:stone => book.cell(i, 'D').to_i,
# 		:gold => book.cell(i, 'E').to_i,
# 		:time => book.cell(i, 'G').to_i,
# 		:population => book.cell(i, 'F').to_i
# 	}
# 	property = {
# 		:wood_inc => book.cell(i, 'B').to_i,
# 	}
# 	reward = {
# 		:experience => book.cell(i, 'h').to_i,
# 		:score => book.cell(i, 'i').to_i,
# 	}
# 	TECHNOLOGIES[TECH_2][level] ||= {}
# 	TECHNOLOGIES[TECH_2][level] = {
# 		:condition => condition,
# 		:cost => cost, 
# 		:property => property,
# 		:reward => reward
# 	}
# end

# book.default_sheet = '采石技术'
# 3.upto(book.last_row).each do |i|
# 	level = book.cell(i, 'A').to_i
# 	condition = {:player_level => book.cell(i, 'j').to_i}
# 	cost = {
# 		:wood => book.cell(i, 'C').to_i,
# 		:stone => book.cell(i, 'D').to_i,
# 		:gold => book.cell(i, 'E').to_i,
# 		:population => book.cell(i, 'F').to_i,
# 		:time => book.cell(i, 'G').to_i,
# 	}
# 	property = {
# 		:stone_inc => book.cell(i, 'B').to_i,
# 	}
# 	reward = {
# 		:experience => book.cell(i, 'H').to_i,
# 		:score => book.cell(i, 'i').to_i,
# 	}
# 	TECHNOLOGIES[TECH_3][level] ||= {}
# 	TECHNOLOGIES[TECH_3][level] = {
# 		:condition => condition,
# 		:cost => cost, 
# 		:property => property,
# 		:reward => reward
# 	}
# end

# book.default_sheet = '狩猎技术'
# 3.upto(book.last_row).each do |i|
# 	level = book.cell(i, 'A').to_i
# 	condition = {:player_level => book.cell(i, 'j').to_i}
# 	cost = {
# 		:wood => book.cell(i, 'C').to_i,
# 		:stone => book.cell(i, 'D').to_i,
# 		:gold => book.cell(i, 'E').to_i,
# 		:population => book.cell(i, 'F').to_i,
# 		:time => book.cell(i, 'G').to_i,
# 	}
# 	property = {
# 		:meat_inc => book.cell(i, 'B').to_i,
# 	}
# 	reward = {
# 		:experience => book.cell(i, 'H').to_i,
# 		:score => book.cell(i, 'i').to_i,
# 	}
# 	TECHNOLOGIES[TECH_4][level] ||= {}
# 	TECHNOLOGIES[TECH_4][level] = {
# 		:condition => condition,
# 		:cost => cost, 
# 		:property => property,
# 		:reward => reward
# 	}
# end

# book.default_sheet = '采集技术'
# 3.upto(book.last_row).each do |i|
# 	level = book.cell(i, 'A').to_i
# 	condition = {:player_level => book.cell(i, 'j').to_i}
# 	cost = {
# 		:wood => book.cell(i, 'C').to_i,
# 		:stone => book.cell(i, 'D').to_i,
# 		:gold => book.cell(i, 'E').to_i,
# 		:population => book.cell(i, 'F').to_i,
# 		:time => book.cell(i, 'G').to_i,
# 	}
# 	property = {
# 		:fruit_inc => book.cell(i, 'B').to_i,
# 	}
# 	reward = {
# 		:experience => book.cell(i, 'H').to_i,
# 		:score => book.cell(i, 'i').to_i,
# 	}
# 	TECHNOLOGIES[TECH_5][level] ||= {}
# 	TECHNOLOGIES[TECH_5][level] = {
# 		:condition => condition,
# 		:cost => cost, 
# 		:property => property,
# 		:reward => reward
# 	}
# end

# book.default_sheet = '储藏技术'
# 3.upto(book.last_row).each do |i|
# 	level = book.cell(i, 'A').to_i
# 	condition = {:player_level => book.cell(i, 'j').to_i}
# 	cost = {
# 		:wood => book.cell(i, 'C').to_i,
# 		:stone => book.cell(i, 'D').to_i,
# 		:gold => book.cell(i, 'E').to_i,
# 		:population => book.cell(i, 'F').to_i,
# 		:time => book.cell(i, 'G').to_i,
# 	}
# 	property = {
# 		:resource_max => book.cell(i, 'B').to_i,
# 	}
# 	reward = {
# 		:experience => book.cell(i, 'H').to_i,
# 		:score => book.cell(i, 'i').to_i,
# 	}
# 	TECHNOLOGIES[TECH_6][level] ||= {}
# 	TECHNOLOGIES[TECH_6][level] = {
# 		:condition => condition,
# 		:cost => cost, 
# 		:property => property,
# 		:reward => reward
# 	}
# end

# book.default_sheet = '孵化技术'
# 3.upto(book.last_row).each do |i|
# 	level = book.cell(i, 'A').to_i
# 	condition = {:player_level => book.cell(i, 'l').to_i}
# 	cost = {
# 		:wood => book.cell(i, 'e').to_i,
# 		:stone => book.cell(i, 'f').to_i,
# 		:gold => book.cell(i, 'g').to_i,
# 		:population => book.cell(i, 'h').to_i,
# 		:time => book.cell(i, 'i').to_i,
# 	}
# 	property = {
# 		:eggs_max => book.cell(i, 'B').to_i,
# 		:hatch_max => book.cell(i, 'C').to_i,
# 		:hatch_efficiency => book.cell(i, 'd').to_i
# 	}
# 	reward = {
# 		:experience => book.cell(i, 'j').to_i,
# 		:score => book.cell(i, 'k').to_i,
# 	}
# 	TECHNOLOGIES[TECH_7][level] ||= {}
# 	TECHNOLOGIES[TECH_7][level] = {
# 		:condition => condition,
# 		:cost => cost, 
# 		:property => property,
# 		:reward => reward
# 	}
# end

# book.default_sheet = '驯养技术'
# 3.upto(book.last_row).each do |i|
# 	level = book.cell(i, 'A').to_i
# 	condition = {:player_level => book.cell(i, 'k').to_i}
# 	cost = {
# 		:wood => book.cell(i, 'd').to_i,
# 		:stone => book.cell(i, 'e').to_i,
# 		:gold => book.cell(i, 'f').to_i,
# 		:population => book.cell(i, 'g').to_i,
# 		:time => book.cell(i, 'h').to_i,
# 	}
# 	property = {
# 		:dinosaur_max => book.cell(i, 'B').to_i,
# 		:training_max => book.cell(i, 'C').to_i
# 	}
# 	reward = {
# 		:experience => book.cell(i, 'i').to_i,
# 		:score => book.cell(i, 'j').to_i,
# 	}
# 	TECHNOLOGIES[TECH_8][level] ||= {}
# 	TECHNOLOGIES[TECH_8][level] = {
# 		:condition => condition,
# 		:cost => cost, 
# 		:property => property,
# 		:reward => reward
# 	}
# end

# book.default_sheet = '商业技术'
# 3.upto(book.last_row).each do |i|
# 	level = book.cell(i, 'A').to_i
# 	condition = {:player_level => book.cell(i, 'k').to_i}
# 	cost = {
# 		:wood => book.cell(i, 'd').to_i,
# 		:stone => book.cell(i, 'e').to_i,
# 		:gold => book.cell(i, 'f').to_i,
# 		:population => book.cell(i, 'g').to_i,
# 		:time => book.cell(i, 'h').to_i,
# 	}
# 	property = {
# 		:transport_effeciency => book.cell(i, 'B').to_f,
# 		:tax => book.cell(i, 'C').to_f
# 	}
# 	reward = {
# 		:experience => book.cell(i, 'i').to_i,
# 		:score => book.cell(i, 'j').to_i,
# 	}
# 	TECHNOLOGIES[TECH_9][level] ||= {}
# 	TECHNOLOGIES[TECH_9][level] = {
# 		:condition => condition,
# 		:cost => cost, 
# 		:property => property,
# 		:reward => reward
# 	}
# end

# book.default_sheet = '科研技术'
# 3.upto(book.last_row).each do |i|
# 	level = book.cell(i, 'A').to_i
# 	condition = {:player_level => book.cell(i, 'j').to_i}
# 	cost = {
# 		:wood => book.cell(i, 'C').to_i,
# 		:stone => book.cell(i, 'D').to_i,
# 		:gold => book.cell(i, 'E').to_i,
# 		:population => book.cell(i, 'F').to_i,
# 		:time => book.cell(i, 'G').to_i,
# 	}
# 	property = {
# 		:research_effectiency => book.cell(i, 'B').to_f,
# 	}
# 	reward = {
# 		:experience => book.cell(i, 'H').to_i,
# 		:score => book.cell(i, 'i').to_i,
# 	}
# 	TECHNOLOGIES[TECH_10][level] ||= {}
# 	TECHNOLOGIES[TECH_10][level] = {
# 		:condition => condition,
# 		:cost => cost, 
# 		:property => property,
# 		:reward => reward
# 	}
# end

# book.default_sheet = '祭祀技术'
# 3.upto(book.last_row).each do |i|
# 	level = book.cell(i, 'A').to_i
# 	condition = {:player_level => book.cell(i, 'j').to_i}
# 	cost = {
# 		:wood => book.cell(i, 'C').to_i,
# 		:stone => book.cell(i, 'D').to_i,
# 		:gold => book.cell(i, 'E').to_i,
# 		:population => book.cell(i, 'F').to_i,
# 		:time => book.cell(i, 'G').to_i,
# 	}
# 	property = {
# 		:pray_effectiency => book.cell(i, 'B').to_f,
# 	}
# 	reward = {
# 		:experience => book.cell(i, 'H').to_i,
# 		:score => book.cell(i, 'i').to_i,
# 	}
# 	TECHNOLOGIES[TECH_11][level] ||= {}
# 	TECHNOLOGIES[TECH_11][level] = {
# 		:condition => condition,
# 		:cost => cost, 
# 		:property => property,
# 		:reward => reward
# 	}
# end


# book.default_sheet = '炼金'
# 3.upto(book.last_row).each do |i|
# 	level = book.cell(i, 'A').to_i
# 	condition = {:player_level => book.cell(i, 'j').to_i}
# 	cost = {
# 		:wood => book.cell(i, 'C').to_i,
# 		:stone => book.cell(i, 'D').to_i,
# 		:gold => book.cell(i, 'E').to_i,
# 		:population => book.cell(i, 'F').to_i,
# 		:time => book.cell(i, 'G').to_i,
# 	}
# 	property = {
# 		:extra_gold => book.cell(i, 'B').to_f,
# 	}
# 	reward = {
# 		:experience => book.cell(i, 'H').to_i,
# 		:score => book.cell(i, 'i').to_i,
# 	}
# 	TECHNOLOGIES[TECH_12][level] ||= {}
# 	TECHNOLOGIES[TECH_12][level] = {
# 		:condition => condition,
# 		:cost => cost, 
# 		:property => property,
# 		:reward => reward
# 	}
# end

# book.default_sheet = '勇气'
# 3.upto(book.last_row).each do |i|
# 	level = book.cell(i, 'A').to_i
# 	condition = {:player_level => book.cell(i, 'j').to_i}
# 	cost = {
# 		:wood => book.cell(i, 'C').to_i,
# 		:stone => book.cell(i, 'D').to_i,
# 		:gold => book.cell(i, 'E').to_i,
# 		:population => book.cell(i, 'F').to_i,
# 		:time => book.cell(i, 'G').to_i,
# 	}
# 	property = {
# 		:attack_inc => book.cell(i, 'B').to_f,
# 	}
# 	reward = {
# 		:experience => book.cell(i, 'H').to_i,
# 		:score => book.cell(i, 'i').to_i,
# 	}
# 	TECHNOLOGIES[TECH_13][level] ||= {}
# 	TECHNOLOGIES[TECH_13][level] = {
# 		:condition => condition,
# 		:cost => cost, 
# 		:property => property,
# 		:reward => reward
# 	}
# end

# book.default_sheet = '刚毅'
# 3.upto(book.last_row).each do |i|
# 	level = book.cell(i, 'A').to_i
# 	condition = {:player_level => book.cell(i, 'j').to_i}
# 	cost = {
# 		:wood => book.cell(i, 'C').to_i,
# 		:stone => book.cell(i, 'D').to_i,
# 		:gold => book.cell(i, 'E').to_i,
# 		:population => book.cell(i, 'F').to_i,
# 		:time => book.cell(i, 'G').to_i,
# 	}
# 	property = {
# 		:defense_inc => book.cell(i, 'B').to_f,
# 	}
# 	reward = {
# 		:experience => book.cell(i, 'H').to_i,
# 		:score => book.cell(i, 'i').to_i,
# 	}
# 	TECHNOLOGIES[TECH_14][level] ||= {}
# 	TECHNOLOGIES[TECH_14][level] = {
# 		:condition => condition,
# 		:cost => cost, 
# 		:property => property,
# 		:reward => reward
# 	}
# end

# book.default_sheet = '忠诚'
# 3.upto(book.last_row).each do |i|
# 	level = book.cell(i, 'A').to_i
# 	condition = {:player_level => book.cell(i, 'j').to_i}
# 	cost = {
# 		:wood => book.cell(i, 'C').to_i,
# 		:stone => book.cell(i, 'D').to_i,
# 		:gold => book.cell(i, 'E').to_i,
# 		:population => book.cell(i, 'F').to_i,
# 		:time => book.cell(i, 'G').to_i,
# 	}
# 	property = {
# 		:hp_inc => book.cell(i, 'B').to_f,
# 	}
# 	reward = {
# 		:experience => book.cell(i, 'H').to_i,
# 		:score => book.cell(i, 'i').to_i,
# 	}
# 	TECHNOLOGIES[TECH_15][level] ||= {}
# 	TECHNOLOGIES[TECH_15][level] = {
# 		:condition => condition,
# 		:cost => cost, 
# 		:property => property,
# 		:reward => reward
# 	}
# end

# book.default_sheet = '仁义'
# 3.upto(book.last_row).each do |i|
# 	level = book.cell(i, 'A').to_i
# 	condition = {:player_level => book.cell(i, 'j').to_i}
# 	cost = {
# 		:wood => book.cell(i, 'C').to_i,
# 		:stone => book.cell(i, 'D').to_i,
# 		:gold => book.cell(i, 'E').to_i,
# 		:population => book.cell(i, 'F').to_i,
# 		:time => book.cell(i, 'G').to_i,
# 	}
# 	property = {
# 		:trigger_inc => book.cell(i, 'B').to_f,
# 	}
# 	reward = {
# 		:experience => book.cell(i, 'H').to_i,
# 		:score => book.cell(i, 'i').to_i,
# 	}
# 	TECHNOLOGIES[TECH_16][level] ||= {}
# 	TECHNOLOGIES[TECH_16][level] = {
# 		:condition => condition,
# 		:cost => cost, 
# 		:property => property,
# 		:reward => reward
# 	}
# end

# book.default_sheet = '寻宝'
# 3.upto(book.last_row).each do |i|
# 	level = book.cell(i, 'A').to_i
# 	condition = {:player_level => book.cell(i, 'j').to_i}
# 	cost = {
# 		:wood => book.cell(i, 'C').to_i,
# 		:stone => book.cell(i, 'D').to_i,
# 		:gold => book.cell(i, 'E').to_i,
# 		:population => book.cell(i, 'F').to_i,
# 		:time => book.cell(i, 'G').to_i,
# 	}
# 	property = {
# 		:eggfall => book.cell(i, 'B').to_f,
# 	}
# 	reward = {
# 		:experience => book.cell(i, 'H').to_i,
# 		:score => book.cell(i, 'i').to_i,
# 	}
# 	TECHNOLOGIES[TECH_17][level] ||= {}
# 	TECHNOLOGIES[TECH_17][level] = {
# 		:condition => condition,
# 		:cost => cost, 
# 		:property => property,
# 		:reward => reward
# 	}
# end

# book.default_sheet = '残暴'
# 3.upto(book.last_row).each do |i|
# 	level = book.cell(i, 'A').to_i
# 	condition = {:player_level => book.cell(i, 'j').to_i}
# 	cost = {
# 		:wood => book.cell(i, 'C').to_i,
# 		:stone => book.cell(i, 'D').to_i,
# 		:gold => book.cell(i, 'E').to_i,
# 		:population => book.cell(i, 'F').to_i,
# 		:time => book.cell(i, 'G').to_i,
# 	}
# 	property = {
# 		:damage_inc => book.cell(i, 'B').to_f,
# 	}
# 	reward = {
# 		:experience => book.cell(i, 'H').to_i,
# 		:score => book.cell(i, 'i').to_i,
# 	}
# 	TECHNOLOGIES[TECH_18][level] ||= {}
# 	TECHNOLOGIES[TECH_18][level] = {
# 		:condition => condition,
# 		:cost => cost, 
# 		:property => property,
# 		:reward => reward
# 	}
# end

# book.default_sheet = '掠夺'
# 3.upto(book.last_row).each do |i|
# 	level = book.cell(i, 'A').to_i
# 	condition = {:player_level => book.cell(i, 'j').to_i}
# 	cost = {
# 		:wood => book.cell(i, 'C').to_i,
# 		:stone => book.cell(i, 'D').to_i,
# 		:gold => book.cell(i, 'E').to_i,
# 		:population => book.cell(i, 'F').to_i,
# 		:time => book.cell(i, 'G').to_i,
# 	}
# 	property = {
# 		:plunder => book.cell(i, 'B').to_f,
# 	}
# 	reward = {
# 		:experience => book.cell(i, 'H').to_i,
# 		:score => book.cell(i, 'i').to_i,
# 	}
# 	TECHNOLOGIES[TECH_18][level] ||= {}
# 	TECHNOLOGIES[TECH_18][level] = {
# 		:condition => condition,
# 		:cost => cost,
# 		:property => property,
# 		:reward => reward
# 	}
# end

# book.default_sheet = '智慧'
# 3.upto(book.last_row).each do |i|
# 	level = book.cell(i, 'A').to_i
# 	condition = {:player_level => book.cell(i, 'j').to_i}
# 	cost = {
# 		:wood => book.cell(i, 'C').to_i,
# 		:stone => book.cell(i, 'D').to_i,
# 		:gold => book.cell(i, 'E').to_i,
# 		:population => book.cell(i, 'F').to_i,
# 		:time => book.cell(i, 'G').to_i,
# 	}
# 	property = {
# 		:plunder => book.cell(i, 'B').to_f,
# 	}
# 	reward = {
# 		:experience => book.cell(i, 'H').to_i,
# 		:score => book.cell(i, 'i').to_i,
# 	}
# 	TECHNOLOGIES[TECH_20][level] ||= {}
# 	TECHNOLOGIES[TECH_20][level] = {
# 		:condition => condition,
# 		:cost => cost,
# 		:property => property,
# 		:reward => reward
# 	}
# end

# TECHNOLOGIES.extend(ConstHelper::TechnologiesConstHelper)






















