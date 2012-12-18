module CountryDataHelper
	# COUNTRY_SZ 					= 2 															# 国家的数量
	COORD_TRANS_FACTOR 	= 600 														# 坐标的大小
	MAP_MAX_X						= 600
	MAP_MAX_Y						= 600
	TOWN_SZ 						= {:length => 3, :width => 3} 		# 城镇节点的大小
	GOLD_MINE_SZ 				= {:length => 3, :width => 3}			# 金矿节点的大小，默认是正方形
	GOLD_MINE_X_RANGE		= 250..350												# 高级金矿X坐标范围
	GOLD_MINE_Y_RANGE		= 250..350												# 高级金矿Y坐标范围

	module ClassMethods

	end
	
	module InstanceMethods

		[:basic_map_info, :town_nodes_info, :gold_mine_info, :hl_gold_mine_info, :creeps_info].each do |name|
		
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
						return JSON.parse(info)
					else
						data = {}
						JSON.parse(info).map do |k, v|
							data[k.to_i] = v
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
					result_arr << x * COORD_TRANS_FACTOR + y
				end
			end
			return result_arr
		end

		# 根据中心点获取城镇所占的格子index信息，返回数组
		def get_town_nodes(center_x, center_y)
			get_nodes_matrix(center_x - 1, center_y - 1, TOWN_SZ[:length], TOWN_SZ[:width])
		end

		# 根据金矿中心点获取城镇所占格子的index信息，返回数组
		def get_gold_mine_nodes(center_x, center_y)
			get_nodes_matrix(center_x - 1, center_y - 1, GOLD_MINE_SZ[:length], GOLD_MINE_SZ[:width])
		end

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

			# 如果基本信息为空，从文件读取地图的基本信息
			if basic_map_info.nil?
				
				file = File.open Rails.root.join("init_data/tilemap_lgc.txt")
				basic_map_info = file.read.each_char.map { |i| i = i.to_i; i = -1 if i == 1; i }
				

				# 循环每11*11个矩形格子
				15.step(COORD_TRANS_FACTOR - 11, 11) do |x|
					15.step(COORD_TRANS_FACTOR - 11, 11) do |y|
						if x.in?(GOLD_MINE_X_RANGE) && y.in?(GOLD_MINE_Y_RANGE)
							next
						end

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

				gm_available_nodes = {}
				gm_blocked_nodes = {}

				GOLD_MINE_X_RANGE.each do |x|
					GOLD_MINE_Y_RANGE.each do |y|
						idx = x * COORD_TRANS_FACTOR + y
						town_nodes_info.delete(idx)
						gold_mine_info.delete(idx)

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
							nodes_token.each{|n_idx| gm_blocked_nodes[n_idx] = 1}
						end
					end
				end

				# 刷新野怪
				

				self.set_basic_map_info(basic_map_info)
				self.set_town_nodes_info(town_nodes_info)
				self.set_gold_mine_info(gold_mine_info)
				self.set_hl_gold_mine_info(gm_available_nodes)
			end
		end # End of init method.

		# 刷新地图野怪
		def refresh_creeps!
			creeps_info = {}
			15.step(COORD_TRANS_FACTOR - 11, 11) do |x|
				15.step(COORD_TRANS_FACTOR - 11, 11) do |y|
					m_x, m_y = nil, nil 
					until !m_x.nil? && !m_y.nil?
						m_x, m_y = get_random_node_in_a_matrix(x, y, 9, 9)
						m_idx = m_x * COORD_TRANS_FACTOR + m_y
						if basic_map_info[m_idx] >= 0 && town_nodes_info[m_idx].nil? && gold_mine_info[m_idx].nil? && hl_gold_mine_info[m_idx].nil?
							creeps_info[m_idx] = 1
						end
					end
				end
			end
			set_creeps_info(creeps_info)
		end


		# 清除地图城镇、金矿信息
		def clear!
			db.multi do |t|
				t.del(self.basic_map_info_key)
				t.del(self.town_nodes_info_key)
				t.del(self.gold_mine_info_key)
				t.del(self.creeps_info_key)
				eval("$country_#{index}_basic_map_info = nil")
				eval("$country_#{index}_town_nodes_info = nil")
				eval("$country_#{index}_gold_mine_info = nil")
				eval("$country_#{index}_creeps_info = nil")
			end
		end

		# 重新生成地图信息
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end









