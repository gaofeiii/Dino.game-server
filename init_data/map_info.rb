p '--- Initializing country and maps info ---'
country = Country.with(:index, 1)
country = Country.create(:index => 1) if country.nil?
$country_map = []
$village_info = {}

if country.get_map.blank?
	map_info = Ohm.redis.get :country_map

	unless map_info.nil?
		$country_map = JSON.parse(map_info)
	else
		file = File.open Rails.root.join("init_data/tilemap_lgc.txt")
		blocked_info = file.read
		$country_map = blocked_info.each_char.map{|i| i = i.to_i; i = -1 if i == 1; i}

		# TODO: 生成金矿点

		


		# 生成玩家村落的位置点
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

							((rx-1)..(rx+1)).each do |sx|
								((ry-1)..(ry+1)).each do |sy|
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
				
				((rx-1)..(rx+1)).each do |sx|
					((ry-1)..(ry+1)).each do |sy|
						$country_map[town_index] = -1
					end
				end

				$country_map[town_index] = 1
				$village_info[town_index] = 1
			end
		end
	end

end
















