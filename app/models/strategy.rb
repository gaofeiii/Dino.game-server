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

	def dinosaur_ids
		if self.dinosaurs.blank?
			return []
		end

		re = JSON(dinosaurs)
		if re.is_a?(Array)
			re.select {|d_id| d_id > 0 }
		else
			[]
		end
	end
end