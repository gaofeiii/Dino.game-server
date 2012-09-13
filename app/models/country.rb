class Country < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Callbacks
	include OhmExtension

	attribute :index, Type::Integer
	unique :index

	# collection :area_maps, 	AreaMap
	def map_key
		"Country:#{index}:map"
	end

	def map(min='-inf', max='+inf')
		Ohm.redis.zrangebyscore(map_key, min, max)
	end


	def after_delete
		Ohm.redis.del map_key
	end

	# 
end
