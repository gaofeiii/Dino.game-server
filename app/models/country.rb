class Country < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Callbacks
	include OhmExtension

	attribute :index, Type::Integer
	unique :index

	# Map methods:
	def set_map(arr1, arr2)
		Ohm.redis.multi do |t|
			t.zadd "Country:#{index}:map:x_indices", arr1
			t.zadd "Country:#{index}:map:y_indices", arr2
		end
	end

	# def basic_map_info
	# 	info = db.get(key[:basic_map_info])
	# 	return info.nil? ? nil : JSON.parse(info)
	# end

	[:basic_map_info, :town_nodes_info, :gold_mine_info].each do |name|
		
		define_method("#{name.to_s}_key") do
			key[name]
		end

		define_method(name) do
			eval("
				$country_#{index}_#{name.to_s} ||= get_#{name.to_s}
			")
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
	end

	# def country_nodes_info
		
	# end

	# def gold_mine_info
		
	# end

	# def get_map
	# 	# Ohm.redis.zrangebyscore("Country:#{index}:map:x_indices", '-inf', '+inf')
	# 	# $country_map
	# 	info = db.get key[:map_info]
	# 	if info
	# 		nil
	# 	else
	# 		JSON.parse(info)
	# 	end
	# end

	protected

	def after_delete
		# Clear up town and gold indices info.
		db.del(key[:town_nodes_info])
		db.del(key[:basic_map_info])
		db.del(key[:gold_mine_info])
	end

end
