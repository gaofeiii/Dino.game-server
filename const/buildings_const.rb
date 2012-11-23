# # encoding: utf-8
# p '--- Reading buildings const ---'

# BUILDING_1		= 1 	# 民居
# BUILDING_2		= 2		# 伐木场
# BUILDING_3		= 3		# 采石场
# BUILDING_4		= 4		# 狩猎场
# BUILDING_5		= 5		# 采集场
# BUILDING_6		= 6		# 孵化园，栖息地
# BUILDING_7		= 7		# 兽栏
# BUILDING_8		= 8		# 市场
# BUILDING_9		= 9		# 工坊
# BUILDING_10		= 10	# 神庙
# BUILDING_11		= 11	# 仓库

# BUILDINGS = {
# 	BUILDING_1 	=> {:name => :residential},
# 	BUILDING_2 	=> {:name => :lumber_mill},
# 	BUILDING_3 	=> {:name => :quarry},
# 	BUILDING_4 	=> {:name => :hunting_field},
# 	BUILDING_5 	=> {:name => :collecting_farm},
# 	BUILDING_6 	=> {:name => :habitat},
# 	BUILDING_7 	=> {:name => :beastiary},
# 	BUILDING_8 	=> {:name => :market},
# 	BUILDING_9 	=> {:name => :workshop},
# 	BUILDING_10 => {:name => :temple},
# 	BUILDING_11 => {:name => :warehouse},
# }

# BUILDING_TYPES = BUILDINGS.keys
# BUILDING_NAMES = BUILDINGS.values.map{|v| v[:name]}



# file_path = "#{Rails.root}/const/game_numerics/buildings.xlsx"
# book = Excelx.new file_path
# book.default_sheet = "建造列表"

# 2.upto(book.last_row) do |i|
# 	b_type = book.cell(i, 'B').to_i
# 	cost = {
# 		:time => book.cell(i, 'G').to_i,
# 		:wood => book.cell(i, 'C').to_i,
# 		:stone => book.cell(i, 'D').to_i,
# 		:gold => book.cell(i, 'E').to_i,
# 		:population => book.cell(i, 'F').to_i
# 	}
# 	reward = {
# 		:experience => book.cell(i, 'H').to_i,
# 		:score => book.cell(i, 'I').to_i
# 	}
# 	BUILDINGS[b_type] ||= {}
# 	BUILDINGS[b_type].merge!(:cost => cost, :reward => reward)
# end


# BUILDINGS.extend(ConstHelper::BuildingConstHelper)













