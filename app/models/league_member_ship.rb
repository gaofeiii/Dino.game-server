class LeagueMemberShip < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include OhmExtension

	attribute :player_id
	reference :league, League

	attribute :nickname
	attribute :alias_name
	attribute :level, 	Type::Integer

	def to_hash
		{
			:player_id => player_id,
			:nickname => nickname,
			:alias_name => alias_name,
			:level => level
		}
	end

end
