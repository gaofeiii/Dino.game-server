class Monster < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include OhmExtension

	include MonsterConst
	include Fighter

	TYPES = [1, 2, 3, 4, 5, 6]

	STATUS = {
		:egg 			=> 0,
		:infancy 	=> 1, 
		:adult 		=> 2
	}

	attribute 	:level, 		Type::Integer
	attribute 	:type,			Type::Integer
	attribute		:status, 		Type::Integer
	attribute 	:quality,		Type::Integer
	attribute 	:name

	reference 	:gold_mine, GoldMine
	reference		:cave,			PlayerCave
	attribute		:creeps_id

	index :creeps_id

	# args = {:level => 1, :type => 1}
	def self.new_by(args = {})
		if args[:level].nil?
			args[:level] ||= 1
		end

		if args[:type].nil?
			args[:type] = TYPES.sample
		end

		const_info = self.const[args[:level]]
		_monster = self.new args.merge(
												:total_attack => const_info[:attack],
												:total_defense => const_info[:defense],
												:total_agility => const_info[:agility],
												:total_hp => const_info[:hp]
												)
												

		return _monster
	end

	def self.create_by(args = {})
		self.new_by(args).save
	end

	protected

	def before_create
		self.current_hp = self.total_hp
	end

end