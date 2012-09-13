
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

if Country.all.blank?
	p '--- Initializing country and maps info ---'

	country = Country.create :index => 1
	file = File.open Rails.root.join("init_data/tilemap_lgc.txt")

	blocked_info = file.read

	0.upto(299) do |x|
		0.upto(299) do |y|
			blk = blocked_info[x + y * 300]
			AreaMap.create :x => x, :y => y, :blocked => blk
		end
	end

end














