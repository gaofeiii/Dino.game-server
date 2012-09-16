
# if Country.all.blank?
# 	p '--- Initializing country and maps info ---'

# 	country = Country.create :index => 1
# 	file = File.open Rails.root.join("init_data/tilemap_lgc.txt")
# 	$country_map = {}
# 	blocked_info = file.read
# 	x_indices_info = []
# 	y_indices_info = []

# 	0.upto(299) do |x|
# 		0.upto(299) do |y|
# 			blk = blocked_info[x + y * 300]
# 			json = {:x => x, :y => y, :status => blk}.to_json
# 			x_indices_info << [x*1000+y, json]
# 			y_indices_info << [y*1000+x, json]
# 		end
# 	end

# 	Ohm.redis.zadd(country.map_key, info)
# end

# if Country.all.blank?
	


	# country = Country.create :index => 1
	# file = File.open Rails.root.join("init_data/tilemap_lgc.txt")

	# blocked_info = file.read

	# 使用redis的hash存储二级地图信息

	# info = []
	# 0.upto(299) do |x|
	# 	0.upto(299) do |y|
	# 	# 	blk = blocked_info[x + y * 300]
	# 	# 	AreaMap.create :x => x, :y => y, :blocked => blk
	# 		key = x * 10000 + y
	# 		blk = blocked_info[x + y * 300]
	# 		info << [key, {:x => x, :y => y, :blocked => blk}.to_json]
	# 	end
	# end
	# Ohm.redis.del country.map_key
	# Ohm.redis.hmset country.map_key, info.flatten
# end

# ================================== Sorted Set======================================
p '--- Initializing country and maps info ---'

# 使用redis的Sorted Set存储二级地图信息

# country = Country.with(:index, 1)
# country = Country.create(:index => 1) if country.nil?

# if country.get_map.blank?
# 	file = File.open Rails.root.join("init_data/tilemap_lgc.txt")
# 	blocked_info = file.read

# 	info1 = []
# 	info2 = []

# 	0.upto(299) do |x|
# 		0.upto(299) do |y|
# 			key1 = x * 10000 + y
# 			key2 = x + y * 10000
# 			blk = blocked_info[x + y * 300]
# 			info1 << [key1, {:x => x, :y => y, :blocked => blk}.to_json]
# 			info2 << [key2, {:x => x, :y => y, :blocked => blk}.to_json]
# 		end
# 	end

# 	country.init_map(info1, info2)
# end








# ================================== Ruby Array =====================================
country = Country.with(:index, 1)
country = Country.create(:index => 1) if country.nil?
$country_map = []

if country.get_map.blank?
	map_info = Ohm.redis.get :country_map

	unless map_info.nil?
		$country_map = JSON.parse(map_info)
	else
		file = File.open Rails.root.join("init_data/tilemap_lgc.txt")
		blocked_info = file.read
		$country_map = blocked_info.each_char.map{|i| i = i.to_i; i = -1 if i == 1; i}

		15.step(289, 9) do |x|
			15.step(289, 9) do |y|
				
				a = []
				b = []
				c = []

				((x-3)..(x+4)).each do |rx|
					((y-3)..(y+4)).each do |ry|
						index = rx + ry * 300
						if $country_map[index] < 0
							b << index

							(((rx-1)..(rx+1))).each do |sx|
								(((ry-1)..(ry+1))).each do |sy|
									b << sx + sy * 300
								end
							end

						else
							a << index
						end
					end
				end
				a.uniq!
				b.uniq!
				c = a - b

				town_index = c.sample
				ry = town_index / 300
				rx = town_index % 300
				
				(((rx-1)..(rx+1))).each do |sx|
					(((ry-1)..(ry+1))).each do |sy|
						$country_map[sx + sy * 300] = -1
					end
				end

				$country_map[rx + ry * 300] = 1

			end
		end
	end

end
















