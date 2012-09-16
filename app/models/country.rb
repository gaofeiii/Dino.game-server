class Country < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Callbacks
	include OhmExtension

	attribute :index, Type::Integer
	unique :index

	# collection :area_maps, 	AreaMap


	def after_delete
		Ohm.redis.del map_key
	end

	# Map methods:
	def set_map(arr1, arr2)
		Ohm.redis.multi do |t|
			t.zadd "Country:#{index}:map:x_indices", arr1
			t.zadd "Country:#{index}:map:y_indices", arr2
		end
	end

	def get_map
		# Ohm.redis.zrangebyscore("Country:#{index}:map:x_indices", '-inf', '+inf')
		$country_map
	end

end
