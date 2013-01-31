class LeagueMemberShip < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include OhmExtension

	LEVELS = {
		:president => 10,
		:vice_president => 9,
		:member => 1
	}

	attribute :player_id
	reference :league, League

	attribute :alias_name
	attribute :level, 	Type::Integer
	attribute :contribution, Type::Integer

	def self.levels
		LEVELS
	end

	def nickname
		db.hget("Player:#{player_id}", :nickname)
	end

	def to_hash
		{
			:player_id => player_id.to_i,
			:nickname => nickname,
			:position => level,
			:level => Player.get(player_id, :level).to_i,
			:contribution => contribution
		}
	end

end
