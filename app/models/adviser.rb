class Adviser < Ohm::Model

	TAX = 0.01

	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension

	attribute :player_id
	unique :player_id
	attribute :price, 	Type::Integer
	attribute :hired, 	Type::Boolean
	attribute :time, 		Type::Integer

	index :player_id
	index :price

	class << self
		def apply_adviser(player, prc)
			self.create :player_id => player.id, :price => prc
		end
	end

	def player
		Player[player_id]
	end

	def to_hash
		nickname, level = Player.gets(player_id, :nickname, :level)
		{
			:id => id.to_i,
			:player_id => player_id,
			:nickname => nickname,
			:level => level.to_i,
			:price => price
		}
	end
end
