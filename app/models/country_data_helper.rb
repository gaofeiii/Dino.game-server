module CountryDataHelper
	# COUNTRY_SZ 					= 2 															# 国家的数量
	COORD_TRANS_FACTOR 	= 1000 															# 坐标的大小
	MAP_MAX_X						= 1000
	MAP_MAX_Y						= 1000
	TOWN_SZ 						= {:length => 2, :width => 2} 		# 城镇节点的大小
	GOLD_MINE_SZ 				= {:length => 2, :width => 2}			# 金矿节点的大小，默认是正方形
	GOLD_MINE_X_RANGE		= 450..550												# 高级金矿X坐标范围
	GOLD_MINE_Y_RANGE		= 450..550												# 高级金矿Y坐标范围

	TYPE = {
		:village 		=> 1,
		:creeps 		=> 2,
		:gold_mine 	=> 3
	}

	Point = Struct.new(:x, :y, :type) do
		def index
			return (self.x.to_i + (self.y.to_i * COORD_TRANS_FACTOR))
		end
	end

	module ClassMethods
		
	end
	
	module InstanceMethods

		# Define methods like:
		# 	country.basic_map_info
		# 	country.basic_map_info_key
		# 	country.get_basic_map_info # From redis
		# 	country.set_basic_map_info # To redis
		# 	country.clear_basic_map_info
		#
		# The same as:
		# 	def basic_map_info
		# 		if $country_1_basic_map_info.blank?
		# 			$country_1_basic_map_info = get_basic_map_info
		# 		end
		# 		return $country_1_basic_map_info
		# 	end
		[:basic_map_info, :town_nodes_info, :gold_mine_info, :hl_gold_mine_info, :creeps_info, :empty_map_info].each do |name|
		
			define_method("#{name.to_s}_key") do
				key[name]
			end

			define_method(name) do
				code = %Q(
					if $country_#{index}_#{name.to_s}.blank?
						$country_#{index}_#{name.to_s} = get_#{name.to_s}
					end
					return $country_#{index}_#{name.to_s}
					)
				eval(code)
			end

			define_method("get_#{name.to_s}") do
				info = db.get(key[name])

				if info.nil?
					return nil
				else
					case name
					when :basic_map_info
						return JSON(info)
					when :empty_map_info
						return JSON(info)
					else
						data = {}
						JSON.parse(info).map do |k, v|
							data[k.to_i] = v # The key from json is a string, turn it into integer
						end
						return data
					end
				end
			end

			define_method("set_#{name.to_s}") do |info|
				db.set(key[name], info.to_json)
			end

			define_method("clear_#{name.to_s}") do
				db.del(key[name])
				eval("$country_#{index}_#{name.to_s} = nil")
			end
		end

		# 从起点开始，计算所有矩阵格子中的index，并返回所有index的数组
		def get_nodes_matrix(start_x, start_y, offset_x, offset_y)
			result_arr = Array.new
			(start_x..(start_x + offset_x)).each do |x|
				(start_y..(start_y + offset_y)).each do |y|
					result_arr << x + y * COORD_TRANS_FACTOR
				end
			end
			return result_arr
		end
		module_function :get_nodes_matrix

		# 根据中心点获取城镇所占的格子index信息，返回数组
		def get_town_nodes(center_x, center_y)
			get_nodes_matrix(center_x - 1, center_y - 1, TOWN_SZ[:length], TOWN_SZ[:width])
		end
		module_function :get_town_nodes

		# 根据金矿中心点获取城镇所占格子的index信息，返回数组
		def get_gold_mine_nodes(center_x, center_y)
			get_nodes_matrix(center_x - 1, center_y - 1, GOLD_MINE_SZ[:length], GOLD_MINE_SZ[:width])
		end
		module_function :get_gold_mine_nodes

		def get_random_node_in_a_matrix(start_x, start_y, delta_x, delta_y)
			ran_x = rand(start_x..(start_x + delta_x))
			ran_y = rand(start_y..(start_y + delta_y))
			return [ran_x, ran_y]
		end

		# 初始化地图信息
		def init!
			## 地图基本信息
			# => 类型：数组
			# => 数组的下标作为地图坐标的index
			# => 0表示空，-1表示阻挡
			basic_map_info = self.basic_map_info

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

			## 高等级金矿点位置
			# => 类型：Hash
			# => key为地图坐标的index
			# => 1表示有金矿
			# => 金矿所占格子最大为3*3
			hl_gold_mine_info = {}

			## 空白的地图坐标点
			empty_map_info = {}

			# 如果基本信息为空，从文件读取地图的基本信息
			if basic_map_info.nil?
				
				file = File.open Rails.root.join("init_data/tilemap_lgc.txt")
				basic_map_info = file.read.each_char.map { |i| i = i.to_i; i = -1 if i == 1; i }
				# basic_map_info.each_with_index do |info, idx|
				# 	empty_map_info[idx] = info if info >= 0
				# end
				empty_map_info = basic_map_info.dup
				

				# 循环每10*10个矩形格子
				9.step(COORD_TRANS_FACTOR - 10, 10) do |x|
					9.step(COORD_TRANS_FACTOR - 10, 10) do |y|
						if x.in?(GOLD_MINE_X_RANGE) && y.in?(GOLD_MINE_Y_RANGE)
							next
						end

						all_nodes = []						# 所有格子
						town_blocked_nodes = []		# 计算城镇节点时的阻挡格子
						town_available_nodes = []	# 可作为城镇节点的格子

						# 11*11矩形格子中，最外圈不可用，即可用的为9*9
						((x-4)..(x+4)).each do |rx|
							((y-4)..(y+4)).each do |ry|
								idx = rx + ry * COORD_TRANS_FACTOR # 地图节点的实际index
								all_nodes << idx
								t_nodes = get_town_nodes(rx, ry)

								t_nodes.each do |n_idx|
									if basic_map_info[n_idx] < 0
										town_blocked_nodes << n_idx
									end
								end
							end
						end

						# 得到所有可以作为城镇节点的格子信息
						all_nodes.uniq!
						town_blocked_nodes.uniq!
						town_available_nodes = all_nodes - town_blocked_nodes

						2.times do
							town_index = town_available_nodes.sample
							next if town_index.nil?
							town_nodes_info[town_index] = 1
							# town_used_nodes = get_town_nodes(town_index/COORD_TRANS_FACTOR, town_index%COORD_TRANS_FACTOR)
							town_used_nodes = get_nodes_matrix(town_index%COORD_TRANS_FACTOR - 2, town_index/COORD_TRANS_FACTOR - 2, 5, 5) # change town matrix to 5*5
							town_available_nodes -= town_used_nodes
							town_used_nodes.each do |idx|
								empty_map_info[idx] = -1
							end
						end

						gold_available_nodes = town_available_nodes# - get_town_nodes(town_index / COORD_TRANS_FACTOR, town_index % COORD_TRANS_FACTOR)
						gold_index = gold_available_nodes.sample
						if not gold_index.nil?
							gold_mine_info[gold_index] = 3
							# gold_used_nodes = get_gold_mine_nodes(gold_index/COORD_TRANS_FACTOR, gold_index%COORD_TRANS_FACTOR)
							gold_used_nodes = get_nodes_matrix(gold_index%COORD_TRANS_FACTOR - 2, gold_index/COORD_TRANS_FACTOR - 2, 5, 5) # change gold mine martix to 5*5
							gold_used_nodes.each do |idx|
								empty_map_info[idx] = -1
							end
						end
						
					end
				end

				gm_available_nodes = {}
				gm_blocked_nodes = {}

				GOLD_MINE_X_RANGE.each do |x|
					GOLD_MINE_Y_RANGE.each do |y|
						idx = x + y * COORD_TRANS_FACTOR
						town_nodes_info.delete(idx)	# Just make sure no other nodes here.
						gold_mine_info.delete(idx)	# Just make sure no other nodes here.

						if x.in?([GOLD_MINE_X_RANGE.min, GOLD_MINE_X_RANGE.max]) || y.in?([GOLD_MINE_Y_RANGE.min, GOLD_MINE_Y_RANGE.max])
							next
						end

						available = true
						nodes_token = get_gold_mine_nodes(x, y)
						nodes_token.each do |n_idx|
							if basic_map_info[n_idx] < 0 || !gm_blocked_nodes[n_idx].nil?
								available = false
								break
							end
						end

						if available
							gm_available_nodes[idx] = 1
							nodes_token.each do |n_idx|
								gm_blocked_nodes[n_idx] = 1
								empty_map_info[n_idx] = -1
							end
						end
					end
				end

				self.set_basic_map_info(basic_map_info)
				self.set_town_nodes_info(town_nodes_info)
				self.set_gold_mine_info(gold_mine_info)
				self.set_hl_gold_mine_info(gm_available_nodes)
				self.set_empty_map_info(empty_map_info)
			end # End of basic_map_info.nil?
		end # End of init method.

		def init_new!
			basic_info = self.basic_map_info
			town_nodes_info = {}
			gold_mine_info = {}
			hl_gold_mine_info = {}
			empty_map_info = {}

			if basic_info.nil?
				
				file = File.open Rails.root.join("init_data/tilemap_lgc.txt")
				basic_info = file.read.each_char.map { |i| i = i.to_i; i = -1 if i == 1; i }

				empty_map_info = basic_info.dup
				
				## 村落和普通金矿的位置
				9.step(COORD_TRANS_FACTOR - 10, 28) do |x|
					9.step(COORD_TRANS_FACTOR - 10, 28) do |y|
						next if x > COORD_TRANS_FACTOR - 28 || y > COORD_TRANS_FACTOR - 28

						points = [
							# 1
							Point.new(x+3, y+3, 1),
							Point.new(x+10, y+3, 2),
							Point.new(x+10, y+10, 1),
							# 2
							Point.new(x+3, y+17, 1),
							Point.new(x+10, y+17, 2),
							Point.new(x+10, y+24, 1),
							# 3
							Point.new(x+17, y+3, 1),
							Point.new(x+24, y+3, 2),
							Point.new(x+24, y+10, 1),
							# 4
							Point.new(x+17, y+17, 1),
							Point.new(x+24, y+17, 2),
							Point.new(x+24, y+24, 1),
						]

						town_available_nodes = []

						points.each do |point|
							if basic_info[point.index] < 0
								next
							end

							ret = true
							get_town_nodes(point.x, point.y).each do |node|
								if basic_info[node] < 0
									ret = false
									break
								end

								e_point = Point.new(node % COORD_TRANS_FACTOR, node / COORD_TRANS_FACTOR)
								if e_point.x.in?(GOLD_MINE_Y_RANGE) && e_point.y.in?(GOLD_MINE_Y_RANGE)
									ret = false
									break
								end
							end

							if ret
								case point.type
								when 1
									town_nodes_info[point.index] = TYPE[:village]
								when 2
									gold_mine_info[point.index] = TYPE[:gold_mine]
								end
							end

						end # End of points

					end # End of 9.step of y
				end # End of 9.step of x

				# Write to redis
				self.set_basic_map_info(basic_map_info)
				self.set_town_nodes_info(town_nodes_info)
				self.set_gold_mine_info(gold_mine_info)
				self.set_hl_gold_mine_info([])
				self.set_empty_map_info(empty_map_info)

			end # Enf of if basic_map_info.nil?
		end

		# 刷新地图野怪
		def refresh_creeps!
			creeps_info = {}
			15.step(COORD_TRANS_FACTOR - 11, 11) do |x|
				15.step(COORD_TRANS_FACTOR - 11, 11) do |y|
					m_x, m_y = nil, nil 
					until !m_x.nil? && !m_y.nil?
						m_x, m_y = get_random_node_in_a_matrix(x, y, 9, 9)
						m_idx = m_x + m_y * COORD_TRANS_FACTOR
						if basic_map_info[m_idx] >= 0 && town_nodes_info[m_idx].nil? && gold_mine_info[m_idx].nil? && hl_gold_mine_info[m_idx].nil?
							creeps_info[m_idx] = 1
						end
					end
				end
			end
			set_creeps_info(creeps_info)
		end


		# 清除地图城镇、金矿信息
		def clear_map_info!
			db.multi do |t|
				t.del(self.basic_map_info_key)
				t.del(self.town_nodes_info_key)
				t.del(self.gold_mine_info_key)
				t.del(self.creeps_info_key)
				t.del(self.empty_map_info_key)
				eval("$country_#{index}_basic_map_info = nil")
				eval("$country_#{index}_town_nodes_info = nil")
				eval("$country_#{index}_gold_mine_info = nil")
				eval("$country_#{index}_creeps_info = nil")
				eval("$country_#{index}_empty_map_info = nil")
			end
		end

		# 重新生成地图信息
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end









