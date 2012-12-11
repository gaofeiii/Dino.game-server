class Strategy < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension

	attribute :village_id, 		Type::Integer
	attribute :gold_mine_id
	attribute :dinosaurs
	reference :player, 	Player

	index :village_id
	index :gold_mine_id
	index :player_id

	def to_hash
		hash = {}
		hash[:village_id] = village_id if village_id
		hash[:gold_mine_id] = gold_mine_id if gold_mine_id
		hash[:dinosaurs] = JSON.parse(dinosaurs)
		hash
	end
end