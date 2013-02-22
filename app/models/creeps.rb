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

	def self.rewards
		Monster.rewards
	end

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
			when 1
				1
			when 2..5
				2
			when 6..15
				3
			when 16..35
				4
			when 36..80
				5
			else
				1
			end
			@mons = m_count.times.map{ Monster.create_by(:level => level, :type => type, :status => Monster::STATUS[:adult], :creeps_id => id) }
		end
		@mons
	end

	def reward
		Creeps.rewards[type]
	end

	protected
	def before_save
		if index.zero?
			self.index = x + y * Country::COORD_TRANS_FACTOR
		end
	end

end
