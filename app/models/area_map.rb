class AreaMap < Ohm::Model

	TYPE = {
		:blocked => -1,
		:empty => 0,
		:village => 1,
		:monster => 2,
		:gold_mine => 3
	}

	include Ohm::DataTypes
	include Ohm::Callbacks
	include OhmExtension
	
	attribute :x, 			Type::Integer
	attribute :y, 			Type::Integer
	attribute :blocked,	Type::Boolean
	attribute :info, 		Type::Hash

	index :x
	index :y
	index :blocked

	reference :country, 	Country
	index :country_id

	def to_hash
		hash = {
			:x => x,
			:y => y,
			:info => {}
		}
		hash
	end

	protected
	def after_save
		Ohm.redis.zadd("AreaMap:sorts:x", x, id)
		Ohm.redis.zadd("AreaMap:sorts:y", y, id)
	end
end
