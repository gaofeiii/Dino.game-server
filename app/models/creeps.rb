class Creeps < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension

	attribute :type, 							Type::Integer
	attribute :level, 						Type::Integer
	attribute :number, 						Type::Integer
	attribute :monster_number, 		Type::Integer
	attribute :x, 								Type::Integer
	attribute :y, 								Type::Integer
	attribute :index, 						Type::Integer
	attribute :under_attack, 			Type::Boolean
	attribute :is_quest_monster, 	Type::Boolean
	attribute :player_id

	index :x
	index :y
	index :index

	# collection :monsters, 	Monster

	def monsters
		Monster.find(:creeps_id => id)
	end

	# def defense_troops
	# 	if self.monsters.blank?
	# 		m_type = type
	# 		m_count = level + 1

	# 		m_count.times{ Monster.new_by(:type => m_type, :status => Monster::STATUS[:adult], :creeps_id => id) }
	# 		self.set :number, m_count
	# 	end
	# 	monsters.to_a
	# end

	def defense_troops
		if @mons.nil?
			m_count = case level
			when 1..5
				1
			when 6..10
				2
			when 11..20
				3
			when 20..30
				4
			else
				5
			end
			@mons = m_count.times.map{ Monster.new_by(:level => level, :type => type, :status => Monster::STATUS[:adult]) }
		end
		@mons
	end

	def before_save
		if index.zero?
			self.index = x * Country::COORD_TRANS_FACTOR + y
		end
	end

end
