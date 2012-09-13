class WorldMapController < ApplicationController

	def country_map
		x, y = params[:x].to_i, params[:y].to_i
		last_x, last_y = params[:last_x].to_i, params[:last_y].to_i

		map_info = []
		# if last_x.nil? or last_y.nil?
			x_ids = Ohm.redis.zrangebyscore("AreaMap:sorts:x", x - 10, x + 10)
			y_ids = Ohm.redis.zrangebyscore("AreaMap:sorts:y", y - 10, y + 10)
			ids = x_ids & y_ids

			ids.each do |i|
				info = AreaMap[i]
				map_info << info.to_hash
			end


			# (x0..x1).each do |i|
			# 	(y0..y1).each do |j|
			# 		info = AreaMap.find(:x => i, :y => j).first
			# 		map_info << info unless info.nil?
			# 	end
			# end

		# end

		
		render :json => {:country_map => map_info}
	end
end
