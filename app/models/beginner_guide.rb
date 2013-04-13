class BeginnerGuide < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension

	MAX_INDEX = 13

	attribute :index,			Type::Integer
	attribute :finished,	Type::Boolean
	attribute :rewarded,	Type::Boolean

	reference :player, 		Player

	index :index
	index :finished
	index :rewarded

	def self.rewards
		@@rewards ||= YAML::load_file("#{Rails.root}/const/beginning_guide.yml").deep_symbolize_keys[:Reward]
		@@rewards
	end

	def to_hash
		{
			:index 		=> index,
			:finished => finished,
			:rewarded => rewarded
		}
	end

	def check
		return true if finished

		@player = self.player

		ret = case index
		when 1 # 修建孵化园
			@player.has_built?(Building.hashes[:habitat])
		when 2 # 孵化恐龙
			@player.dinosaurs.size > 0
		when 3 # 喂养和训练恐龙
			!!@player.beginner_guide_data[:has_fed_dino]
		when 4 # 进攻野怪
			!!@player.beginner_guide_data[:has_attacked_monster]
		when 5 # 治疗恐龙
			!!@player.beginner_guide_data[:has_healed_dino]
		when 6 # 供奉神灵
			!!@player.beginner_guide_data[:has_worshipped_god]
		when 7 # 雇佣军事顾问
			!!@player.beginner_guide_data[:has_hired_advisor]
		when 8 # 攻打副本
			!!@player.beginner_guide_data[:has_attacked_cave]
		when 9 # 升级民居科技
			@player.tech_residential.try(:level).to_i > 0
		when 10 # 防守村庄
			!!@player.beginner_guide_data[:has_set_defense]
		when 11 # 宝石购买恐龙蛋
			!!@player.beginner_guide_data[:has_bought_egg]
		when 12
			!!@player.beginner_guide_data[:egg_evolution]
		when 13 # 刷新任务
			!!@player.beginner_guide_data[:has_opened_quests]
		else
			true
		end

		self.update :finished => ret if ret
	end

	def reward
		data = BeginnerGuide.rewards[index]

		return unless data
		
		Reward.new data
	end

	def is_last?
		index >= MAX_INDEX
	end
end