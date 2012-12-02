class Advisor < Ohm::Model

	TAX = 0.01
	TYPE = {:produce => 1, :military => 2, :business => 3, :technology => 4}

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
	attribute :type, 		Type::Integer

	index :player_id
	index :price
	index :hired
	index :type

	class << self
		def apply_advisor(player, prc)
			self.create :player_id => player.id, :price => prc
		end
	end

	def employer
		Player[player_id]
	end

	def to_hash
		nickname, level = Player.gets(player_id, :nickname, :level)
		{
			:id => id.to_i,
			:player_id => player_id,
			:nickname => nickname,
			:level => level.to_i,
			:type => type,
			:price => price
		}
	end
end
