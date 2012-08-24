# encoding: utf-8
p '--- Reading technologies const ---'
HOUSING = 1
LUMBERING = 2

TECHNOLOGIES = {}

TECHNOLOGIES_names = %w(
	housing
	lumbering
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

	TECHNOLOGIES[HOUSING][level] ||= {}
	TECHNOLOGIES[HOUSING][level] = {
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
		:experience => book.cell(i, 'G').to_i,
		:score => book.cell(i, 'H').to_i,
	}
	TECHNOLOGIES[LUMBERING][level] ||= {}
	TECHNOLOGIES[LUMBERING][level] = {
		:condition => condition,
		:cost => cost, 
		:property => property,
		:reward => reward
	}
end

TECHNOLOGIES.extend(ConstHelper::TechnologiesConstHelper)






















