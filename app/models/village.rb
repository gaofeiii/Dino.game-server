class Village < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Callbacks
	include Ohm::Timestamps
	include Ohm::Locking
	include OhmExtension

	MAX_STEAL_TIME = 3

	attribute :name
	attribute :x, 									Type::Integer
	attribute :y, 									Type::Integer
	attribute :index, 							Type::Integer
	attribute :type,								Type::Integer

	attribute :last_coords,					Type::Integer

	attribute :under_attack, 				Type::Boolean
	attribute :protection_until,		Type::Integer

	attribute :player_id, 					Type::Integer
	attribute :country_index,				Type::Integer

	attribute :strategy_id

	attribute :stolen_count,				Type::Integer
	attribute :last_stolen_time, 		Type::Integer

	collection :buildings, 					Building
	collection :dinosaurs, 					Dinosaur

	index :name
	unique :index
	index :x
	index :y
	index :country_index
	index :type

	TYPE = {
		:normal => 1,
		:dangerous => 2
	}

	# 获取村庄所属的玩家
	def player
		Player[player_id]
	end

	def player_name
		db.hget("Player:#{player_id}", :nickname)
	end

	def level
		(player.level / 10.0).ceil
	end

	def to_hash(*args)
		hash = {
			:id => id.to_s,
			:name => name,
			:x => x,
			:y => y,
			:resources => resources,
			:country_index => country_index,
			:type => type,
			:under_protection => under_protection
		}

		options = if args.include?(:all)
			args + [:strategy, :buildings_with_harvest]
		else
			args
		end

		options.each do |arg|
			case arg
			when :buildings
				hash[:buildings] = buildings.to_a.map(&:update_status!).map(&:to_hash)
			when :buildings_with_harvest
				hash[:buildings] = buildings_info
			when :strategy
				hash[:strategy] = strategy.try(:to_hash)
			end
		end

		hash
	end

	def resources
		warehouse_size = player.tech_warehouse_size
		{
			:wood_max => warehouse_size,
			:stone_max => warehouse_size
		}
	end

	def buildings_info
		buildings.map do |build|
			build.update_status!
			build.to_hash(:harvest_info)
		end
	end

	# def create_building(building_type, level = 1, x, y, st)
	# 	Building.create :type => building_type.to_i, :level => level, :village_id => id, :x => x, :y => y, :status => st
	# end

	# args = { :type => 1, :level => 1, :x => 20, :y => 20, :status => 0, :has_worker => 0 }
	def create_building(args = {})
		args_dup = args.dup
		args_dup.merge!(:level => 1) if args[:level].nil?

		Building.create args_dup.merge(:village_id => id)
	end

	def full_info
		self.to_hash.merge(:buildings => buildings.to_a, :dinosaurs => dinosaurs.to_a)
	end

	def strategy
		Strategy[strategy_id]
	end

	def technology_ids
		db.smembers("Technology:indices:player_id:#{player_id}")
	end

	# Always return a Technology instance.
	def find_tech_by_type(tech_type)
		return nil if not tech_type.in?(Technology.types)

		tech = self.player.technologies.find(:type => tech_type).first
		if tech.nil?
			tech = Technology.create :type => tech_type, :player_id => player_id, :level => 0
		end
		return tech
	end

	def has_built_building?(building_type)
		result = buildings.find(:type => building_type)
		result.any? && result.max{ |b| b.level if b }.try(:status).to_i >= 2
	end

	def country
		if @country.nil?
			@country = Country[db.hget("Player:#{player_id}", :country_id)]
		end
		@country
	end

	def is_bill?
		db.hget("Player:#{player_id}", :player_type).to_i == Player::TYPE[:bill]
	end

	def defense_troops(idx = nil)
		if is_bill?
			monst_info = Player.bill_monsters(idx)

			if monst_info
				mons = monst_info[:monst_num].times.map do
					m_type = (1..5).to_a.sample
					Monster.create_by(:level => monst_info[:monst_level], :type => m_type, :status => Monster::STATUS[:adult])
				end
				return mons
			else
				return []
			end
		end

		str = self.strategy
		if str
			str.dinosaur_ids.map do |d_id|
				dino = Dinosaur[d_id]
				if dino
					dino.current_hp = dino.total_hp
					dino
				end
			end.compact
		else
			[]
		end
	end

	def under_protection
		::Time.now.to_i < protection_until
	end

	def move_to_random_coords
		country = Country.first
		random_coord = (country.town_nodes_info.keys - country.used_town_nodes).sample
		x = random_coord % Country::COORD_TRANS_FACTOR
		y = random_coord / Country::COORD_TRANS_FACTOR
		# self.x = x
		# self.y = y
		# self.index = random_coord
		self.update :x => x, :y => y, :index => random_coord
	end

	def in_dangerous_area?
		x.in?(Country::GOLD_MINE_X_RANGE) && y.in?(Country::GOLD_MINE_Y_RANGE)
	end

	# 得到村落当前资源建筑的数量
	def res_buildings_size
		Building.resource_building_types.sum do |b_type|
			buildings.find(:type => b_type).size
		end
	end

	def self.validate_index
		country = Country.first
		self.all.each do |v|
			country.add_used_town_nodes(v.index)
		end
	end

	protected

	def before_save
		if index.zero?
			self.index = x + y * Country::COORD_TRANS_FACTOR
		end
	end

	def before_create
		self.protection_until = ::Time.now.to_i + 6.hours
	end



	def after_create
		# creeps = Creeps.create :x => x - 2, :y => y - 2, :is_quest_monster => true, :type => 1, :player_id => player_id
		# country.add_quest_monster(creeps.index)

		self.mutex do
			if buildings.find(:type => Building.hashes[:residential]).blank?
				create_building :type => Building.hashes[:residential],
												:level => 1,
												:x => 19,
												:y => 27,
												:status => Building::STATUS[:finished]
				create_building :type => Building.hashes[:arena],
												:level => 1,
												:x => 27,
												:y => 31,
												:status => Building::STATUS[:finished]
				create_building :type => Building.hashes[:workshop],
												:level => 1,
												:x => 15,
												:y => 19,
												:status => Building::STATUS[:finished]
				create_building :type => Building.hashes[:temple],
												:level => 1,
												:x => 22,
												:y => 35,
												:status => Building::STATUS[:finished]
				create_building :type => Building.hashes[:beastiary],
												:level => 1,
												:x => 10,
												:y => 23,
												:status => Building::STATUS[:finished]
				create_building :type => Building.hashes[:market],
												:level => 1,
												:x => 15,
												:y => 32,
												:status => Building::STATUS[:finished]
			end
		end
	end

	def after_delete
		self.buildings.map(&:delete)
	end
end
