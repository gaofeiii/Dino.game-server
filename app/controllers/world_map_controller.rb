class WorldMapController < ApplicationController

	def country_map
		x, y = params[:x], params[:y]
		last_x, last_y = params[:last_x], params[:last_y]

		# map_info = []
		# # if last_x.nil? or last_y.nil?
		# x_ids = Ohm.redis.zrangebyscore("AreaMap:sorts:x", x - 4, x + 4)
		# y_ids = Ohm.redis.zrangebyscore("AreaMap:sorts:y", y - 4, y + 4)
		# ids = x_ids & y_ids

		# ids.each do |i|
		# 	info = AreaMap[i].to_hash
		# 	info[:info].merge!(:type => 1, :name => 'ToT', :id => 12, :level => 2) if rand(1..10) >= 6
		# 	map_info << info
		# end

		x_min = x - 10 <= 0 ? 0 : x - 10
		y_min = y - 10 <= 0 ? 0 : y - 10
		x_max = x + 10 >= 299 ? 299 : x + 10
		y_max = y + 10 >= 299 ? 299 : y + 10

		map_info = []
		# ids_1 = ((x-10)..(x+10)).map do |i|
		# 	((y-10)..(y+10)).map do |j|
		# 		i*10000 + j
		# 	end
		# end.flatten

		# ids_2 = if !last_x.nil? && !last_y.nil?
		# 	last_x = last_x <= 0 ? 0 : last_x
		# 	last_y = last_y <= 0 ? 0 : last_y
		# 	((last_x-10)..(last_x+10)).map do |i|
		# 		((last_y-10)..(last_y+10)).map do |j|
		# 			i*10000 + j
		# 		end
		# 	end.flatten
		# else
		# 	[]
		# end

		ids_1 = (x_min..x_max).map do |i|
			(y_min..y_max).map do |j|
				i + j * 300
			end
		end.flatten

		ids_2 = if !last_x.nil? && !last_y.nil?

			last_x_min = last_x - 10 <= 0 ? 0 : last_x - 10
			last_y_min = last_y - 10 <= 0 ? 0 : last_y - 10
			last_x_max = last_x + 10 >= 299 ? 299 : last_x + 10
			last_y_max = last_y + 10 >= 299 ? 299 : last_y + 10

			(last_x_min..last_x_max).map do |i|
				(last_y_min..last_y_max).map do |j|
					i + j * 300
				end
			end.flatten
		else
			[]
		end


		ids = ids_1 - (ids_1 & ids_2)
		ids.each do |i|
			if $country_map[i] > 0
				map_info << {:x => i % 300, :y => i / 300, :info => {:type => 1, :id => rand(10000), :name => "ToT", :level => rand(1..10)}}
			end
		end
		# map_info = (Ohm.redis.hmget Country.first.map_key, ids).map{|m| JSON.parse(m)}

		render :json => {:country_map => map_info}
	end
end
