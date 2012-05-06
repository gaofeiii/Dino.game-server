# encoding: utf-8
# TODO: [S] 完成buildings的const信息
RESIDENTIAL 			= 1 		# 民居
LUMBER_MILL 			= 2			# 伐木场
QUARRY 						= 3			# 采石场
HUNTING_FIELD 		= 4			# 狩猎场
COLLECTING_FARM 	= 5			# 采集场
HABITAT 					= 6			# 孵化园，栖息地
BEASTIARY 				= 7			# 兽栏
MARKET 						= 8			# 市场
WORKSHOP 					= 9			# 工坊
TEMPLE 						= 10		# 神庙
WAREHOUSE 				= 11		# 仓库


BUILDING_TYPES = (1..11).to_a
BUILDINGS = {}
BUILDING_NAMES = %w(residential lumber_mill quarry hunting_field collecting_farm habitat
	beastiary market workshop temple warehouse).each do |name|
		BUILDINGS[eval(name.upcase)] = {:name => name.to_sym}
	end

file_path = "#{Rails.root}/const/建筑数值表.xlsx"
book = Excelx.new file_path
book.default_sheet = "建造列表"


