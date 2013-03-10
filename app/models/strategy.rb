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

	MAX_COUNT = 5

	def to_hash
		hash = {}
		hash[:village_id] = village_id if village_id
		hash[:gold_mine_id] = gold_mine_id if gold_mine_id
		hash[:dinosaurs] = dinosaurs
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

	# New dinosaurs attr
	def dinosaurs
		if @attributes[:dinosaurs].is_a?(String)
			@attributes[:dinosaurs] = JSON(@attributes[:dinosaurs])
		elsif @attributes[:dinosaurs].blank?
			@attributes[:dinosaurs] = Array.new(MAX_COUNT, -1)
		end
		@attributes[:dinosaurs]
	end

	def save!
		self.dinosaurs = dinosaurs.to_json if dinosaurs.is_a?(Array)
		super
	end

	def dinosaur_ids
		dinosaurs.select{ |d_id| d_id > 0 }
	end

	# idx is 0..4
	def add_dinosaur!(d_id, idx)
		if dinosaur_ids >= MAX_COUNT || idx < 0 || idx > 4
			return false
		else
			self.dinosaurs[idx] = d_id
			save_dinosaurs
		end
	end

	def remove_dinosaur!(d_id)
		self.dinosaurs.map!{|x| x == d_id ? -1 : x}
		save_dinosaurs
	end

	def set_dinosaurs!(ids)
		if ids.is_a?(Array)
			self.dinosaurs = ids
			save_dinosaurs
		end
	end

	def save_dinosaurs
		self.set :dinosaurs, dinosaurs.to_json
	end
	## New dinosaurs attr

	

	def change_defense(new_ids, new_status = 0)
		self.dinosaur_ids.each do |dino_id|
			db.hmset("Dinosaur:#{dino_id}", :action_status, 0, :strategy_id, 0)
		end

		self.set :dinosaurs, new_ids.to_json if new_ids.is_a?(Array)
		new_ids.each do |dino_id|
			db.hmset(Dinosaur.key[dino_id], :action_status, new_status, :strategy_id, id)
		end
	end



end