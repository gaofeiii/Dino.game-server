p '--- Initializing country and maps info ---'

# 从起点开始，计算所有矩阵格子中的index，并返回所有index的数组
def get_nodes_matrix(start_x, start_y, offset_x, offset_y)
	result_arr = Array.new
	(start_x..(start_x + offset_x)).each do |x|
		(start_y..(start_y + offset_y)).each do |y|
			result_arr << x * COORD_TRANS_FACTOR + y
		end
	end
	return result_arr
end

# 根据中心点获取城镇所占的格子index信息，返回数组
def get_town_nodes(center_x, center_y)
	get_nodes_matrix(center_x - 1, center_y - 1, TOWN_SZ[:length], TOWN_SZ[:width])
end

# 
1.upto(COUNTRY_SZ) do |i|
	country = Country.with(:index, i)
	country = Country.create(:index => i) if country.nil?

	## 地图基本信息
	# => 类型：数组
	# => 数组的下标作为地图坐标的index
	# => 0表示空，-1表示阻挡
	basic_map_info = country.basic_map_info

	## 城镇点位的信息
	# => 类型：Hash
	# => key为地图坐标的index
	# => 0表示空城，1表示有人的城市
	# => 城镇所占格子最大为3*3
	town_nodes_info = {}

	## 金矿点位的信息
	# => 类型：Hash
	# => key为地图坐标的index
	# => 1表示有金矿
	# => 金矿所占格子最大为3*3
	gold_mine_info = {}

	# 如果基本信息为空，从文件读取地图的基本信息
	if basic_map_info.nil?
		
		file = File.open Rails.root.join("init_data/tilemap_lgc.txt")
		basic_map_info = file.read.each_char.map { |i| i = i.to_i; i = -1 if i == 1; i }
		

		# 循环每11*11个矩形格子
		15.step(289, 11) do |x|
			15.step(289, 11) do |y|
				all_nodes = []						# 所有格子
				town_blocked_nodes = []		# 计算城镇节点时的阻挡格子
				town_available_nodes = []	# 可作为城镇节点的格子

				# 11*11矩形格子中，最外圈不可用，即可用的为9*9
				((x-4)..(x+4)).each do |rx|
					((y-4)..(y+4)).each do |ry|
						idx = rx * COORD_TRANS_FACTOR + ry # 地图节点的实际index
						all_nodes << idx
						t_nodes = get_town_nodes(rx, ry)
						t_nodes.each do |n_idx|
							if basic_map_info[n_idx] < 0
								town_blocked_nodes << n_idx
								break
							end
						end

					end
				end

				# 得到所有可以作为城镇节点的格子信息
				all_nodes.uniq!
				town_blocked_nodes.uniq!
				town_available_nodes = all_nodes - town_blocked_nodes

				town_index = town_available_nodes.sample
				town_nodes_info[town_index] = 1

				gold_available_nodes = town_available_nodes - get_town_nodes(town_index / COORD_TRANS_FACTOR, town_index % COORD_TRANS_FACTOR)
				gold_index = gold_available_nodes.sample
				gold_mine_info[gold_index] = 3
			end
		end

		country.set_basic_map_info(basic_map_info)
		country.set_town_nodes_info(town_nodes_info)
		country.set_gold_mine_info(gold_mine_info)
	end
end

# =========================== OLD ===========================
# country = Country.with(:index, 1)
# country = Country.create(:index => 1) if country.nil?
# $country_map = []
# $village_info = {}


# if country.get_map.blank?
# 	map_info = Ohm.redis.get :country_map

# 	# $country_map为每个地图格子的信息，类型为数组，大小为x*y
# 	# 若x=300，y=300，$country_map的size为90000
# 	unless map_info.nil?
# 		$country_map = JSON.parse(map_info)
# 	else
# 		file = File.open Rails.root.join("init_data/tilemap_lgc.txt")
# 		blocked_info = file.read
# 		$country_map = blocked_info.each_char.map{|i| i = i.to_i; i = -1 if i == 1; i}

# 		# 生成玩家村落的位置点
# 		# Example:
# 		# 	1. 假设拼接地图的大小为300*300的菱形，四条边预留10个坐标不置放任何地图元素
# 		# 	2. 从(15, 15)点开始循环，步进为11，即在11*11个格子里生成一个城镇点位置
# 		# 	3. 
# 		15.step(289, 11) do |x|
# 			15.step(289, 11) do |y|
				
# 				a = []
# 				b = []
# 				c = []

# 				((x-3)..(x+4)).each do |rx|
# 					((y-3)..(y+4)).each do |ry|
# 						index = rx + ry * COORD_TRANS_FACTOR
# 						if $country_map[index] < 0
# 							b << index

# 							((rx-1)..(rx+1)).each do |sx|
# 								((ry-1)..(ry+1)).each do |sy|
# 									b << sx + sy * COORD_TRANS_FACTOR
# 								end
# 							end

# 						else
# 							a << index
# 						end
# 					end
# 				end
# 				a.uniq!
# 				b.uniq!
# 				c = a - b

# 				town_index = c.sample
# 				ry = town_index / COORD_TRANS_FACTOR
# 				rx = town_index % COORD_TRANS_FACTOR
				
# 				((rx-1)..(rx+1)).each do |sx|
# 					((ry-1)..(ry+1)).each do |sy|
# 						$country_map[town_index] = -1
# 					end
# 				end

# 				$country_map[town_index] = 1
# 				$village_info[town_index] = 1
# 			end
# 		end

# 		# TODO: 生成金矿点

# 	end

# end
















