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

	attribute :nickname
	attribute :alias_name
	attribute :level, 	Type::Integer

	def self.levels
		LEVELS
	end

	def to_hash
		{
			:player_id => player_id.to_i,
			:nickname => nickname,
			:position => level,
			:level => Player.get(player_id, :level).to_i
		}
	end

end
