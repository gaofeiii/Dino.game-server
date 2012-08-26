# encoding: utf-8
p '--- Reading buildings const ---'

BUILDING_RESIDENTIAL 			= 1 		# 民居
BUILDING_LUMBER_MILL 			= 2			# 伐木场
BUILDING_QUARRY 					= 3			# 采石场
BUILDING_HUNTING_FIELD 		= 4			# 狩猎场
BUILDING_COLLECTING_FARM 	= 5			# 采集场
BUILDING_HABITAT 					= 6			# 孵化园，栖息地
BUILDING_BEASTIARY 				= 7			# 兽栏
BUILDING_MARKET 					= 8			# 市场
BUILDING_WORKSHOP 				= 9			# 工坊
BUILDING_TEMPLE 					= 10		# 神庙
BUILDING_WAREHOUSE 				= 11		# 仓库


BUILDING_TYPES = (1..11).to_a
BUILDINGS = {}
BUILDING_NAMES = %w(
	building_residential 
	building_lumber_mill 
	building_quarry 
	building_hunting_field 
	building_collecting_farm 
	building_habitat
	building_beastiary 
	building_market 
	building_workshop 
	building_temple 
	building_warehouse).each do |name|
		BUILDINGS[eval(name.upcase)] = {:name => name.to_sym}
	end

file_path = "#{Rails.root}/const/game_numerics/buildings.xlsx"
book = Excelx.new file_path
book.default_sheet = "建造列表"

2.upto(book.last_row).each do |i|
	b_type = book.cell(i, 'B').to_i
	cost = {
		:time => book.cell(i, 'G').to_i,
		:wood => book.cell(i, 'C').to_i,
		:stone => book.cell(i, 'D').to_i,
		:gold => book.cell(i, 'E').to_i,
		:population => book.cell(i, 'F').to_i
	}
	reward = {
		:experience => book.cell(i, 'H').to_i,
		:score => book.cell(i, 'I').to_i
	}
	BUILDINGS[b_type] = {:cost => cost, :reward => reward}
end


BUILDINGS.extend(ConstHelper::BuildingConstHelper)













