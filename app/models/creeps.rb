class Creeps < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension

	attribute :type, 		Type::Integer
	attribute :level, 	Type::Integer
	attribute :number, 	Type::Integer
	attribute :x, 			Type::Integer
	attribute :y, 			Type::Integer
	attribute :index, 	Type::Integer
	attribute :under_attack, Type::Boolean
	attribute :is_quest_monster, 	Type::Boolean
	attribute :player_id

	index :x
	index :y
	index :index

	# collection :monsters, 	Monster

	def monsters
		Monster.find(:creeps_id => id)
	end

	def defense_troops
		if self.monsters.blank?
			m_type = type
			m_count = level + 1

			m_count.times{ Monster.create_by(:type => m_type, :status => Monster::STATUS[:adult], :creeps_id => id) }
			self.set :number, m_count
		end
		monsters.to_a
	end

	def monster_number
		if number.zero?
			defense_troops
		end
		number
	end

	def before_save
		if index.zero?
			self.index = x * Country::COORD_TRANS_FACTOR + y
		end
	end

end
