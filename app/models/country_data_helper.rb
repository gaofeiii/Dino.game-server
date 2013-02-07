module CountryDataHelper
	# COUNTRY_SZ 					= 2 															# 国家的数量
	COORD_TRANS_FACTOR 	= 1000 															# 坐标的大小
	MAP_MAX_X						= 1000
	MAP_MAX_Y						= 1000
	TOWN_SZ 						= {:length => 2, :width => 2} 		# 城镇节点的大小
	GOLD_MINE_SZ 				= {:length => 2, :width => 2}			# 金矿节点的大小，默认是正方形
	GOLD_MINE_X_RANGE		= 450..550												# 高级金矿X坐标范围
	GOLD_MINE_Y_RANGE		= 450..550												# 高级金矿Y坐标范围

	SPEC_GOLD_MINE_X_RANGE = 470..530
	SPEC_GOLD_MINE_Y_RANGE = 470..530

	TYPE = {
		:village 		=> 1,
		:creeps 		=> 2,
		:gold_mine 	=> 3
	}

	::Point = Struct.new(:x, :y, :type) do
		def index
			return (self.x.to_i + (self.y.to_i * COORD_TRANS_FACTOR))
		end

		def +(other)
			self.class.new(self.x + other.x, self.y + other.y)
		end

		def ==(other)
			if self.x == other.x && self.y == other.y
				return true
			else
				return false
			end
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
		[:basic_map_info, :town_nodes_info, :gold_mine_info, :hl_gold_mine_info, 
			:creeps_info, :empty_map_info].each do |name|
		
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

		# 初始化地图信息 NEW
		def init_new!
			basic_info = self.basic_map_info
			town_nodes_info = {}
			danger_town_nodes_info = {}
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
								if e_point.x.in?(GOLD_MINE_X_RANGE) && e_point.y.in?(GOLD_MINE_Y_RANGE)
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

				## 公会争夺战-危险村庄和特殊金矿的位置
				# 二级地图中，公会战的区域为(450,450)~(550,550)
				# 其中海的区域宽度为10的环状，危险村庄的区域为宽度为10的环状，中间60*60的区域为金矿区
				start_point = Point.new(465, 467)
				end_point = Point.new(535, 537)

				points = []
				start_point.x.step(end_point.x, 5) { |x| points += [Point.new(x, start_point.y + rand(-2..2)), Point.new(x, end_point.y + rand(-2..2))] }
				start_point.y.step(end_point.y, 5) { |y| points += [Point.new(start_point.x + rand(-2..2), y), Point.new(end_point.x + rand(-2..2), y)] }

				points.uniq!
				points.each do |pt|
					ret = true

					get_town_nodes(pt.x, pt.y).each do |node|
						if basic_info[node] < 0
							ret = false
							break
						end
					end

					if ret
						town_nodes_info[pt.index] = TYPE[:village]
					end
				end
				
				gold_start = Point[470, 470]
				gold_end 	 = Point[530, 530]

				gold_start.x.step(gold_end.x - 1, 15) do |x|
					gold_start.y.step(gold_end.y - 1, 15) do |y|

						gold_points = [
							Point.new(x+3, y+3),
							Point.new(x+3, y+11),
							Point.new(x+11, y+3),
							# Point.new(x+11, y+11),
						]

						gold_points.each do |point|
							ret = true
							get_gold_mine_nodes(point.x, point.y).each do |node|
								if basic_info[node] < 0
									ret = false
									break
								end
							end
							if ret
								hl_gold_mine_info[point.index] = TYPE[:gold_mine]
							end
						end
					end
				end

				# Write to redis
				self.set_basic_map_info(basic_map_info)
				self.set_town_nodes_info(town_nodes_info)
				self.set_gold_mine_info(gold_mine_info)
				self.set_hl_gold_mine_info(hl_gold_mine_info)
				self.set_empty_map_info(empty_map_info)
			end # Enf of if basic_map_info.nil?
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









