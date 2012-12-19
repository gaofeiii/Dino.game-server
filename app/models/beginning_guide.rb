# Only included by player model.
# Require ohm, ohm-contrib gems.
# Player model must inhert from Ohm::Model.

## === Example ===
# 
# player = Player.sample
# player.guide_info
# => {}
#
# player.guide_info.current_quest
# => {:index=>1, :finished=>0, :rewarded=>0}
#
# player.guide_info.current_quest.finished?
# => false
#
# player.guide_info.current_quest.finished = true
# => true
#
# player.guide_info.current_quest
# => {:index=>1, :finished=>1, :rewarded=>0}
#
# player.guide_info.current_quest.rewarded = true
# => true
#
# player.guide_info[1]
# => {:index=>1, :finished=>1, :rewarded=>1}
#
# player.guide_info.current_quest
# => {:index=>2, :finished=>0, :rewarded=>0}
module BeginningGuide
	LAST_GUIDE_INDEX = 8
	module ClassMethods
		@@cache = Hash.new
		@@reward = Hash.new

		def beginning_guide_info
			if @@cache.empty?
				@@cache = YAML::load_file("#{Rails.root}/const/beginning_guide.yml").deep_symbolize_keys
			end
			@@cache
		end

		def beginning_guide_reward(index = nil)
			if @@reward.empty?
				@@reward = beginning_guide_info[:Reward]
			end
			
			if index.nil?
				return @@reward
			else
				return @@reward[index.to_i]
			end
		end
	end

	def self.included(model)
		model.attribute :guide_info
		model.attribute :beginning_guide_finished, Ohm::DataTypes::Type::Boolean
		model.attribute :guide_cache, Ohm::DataTypes::Type::Hash
		model.class_eval do
			remove_method :guide_info
		end
		model.extend(ClassMethods)
	end
	
	def save!
		self.guide_info = self.guide_info.except(:player).to_json
		self.guide_cache = {}.to_json if self.guide_cache.nil?
		super
	end

	def guide_info
		if @attributes[:guide_info].kind_of?(Hash) && @attributes[:guide_info].any?
			return @attributes[:guide_info]
		else
			@attributes[:guide_info] = @attributes[:guide_info].nil? ? {} : JSON.parse(@attributes[:guide_info])
			@attributes[:guide_info].keys.each do |key|
				@attributes[:guide_info][(key.to_i rescue key) || key] = @attributes[:guide_info].delete(key).symbolize_keys!.extend(BeginningGuideSingleHelper)
			end
			@attributes[:guide_info][:player] = self
			@attributes[:guide_info].extend(BeginningGuideHelper)
			return @attributes[:guide_info]
		end
	end

	# Check current guide quest.
	def check_current
		
	end

	# The guide reward contains [wood, stone, gold_coin, gem]
	def receive_guide_reward!(rwd = {})
		receive!(rwd)
	end
	
end

module BeginningGuideHelper
	# Get or create guide info.
	def [](index)
		su = super
		unless index.kind_of?(Integer)
			return su
		end

		if su.blank? && index > 0 && index <= BeginningGuide::LAST_GUIDE_INDEX
			su ||= {:index => index, :finished => 0, :rewarded => 0}.extend(BeginningGuideSingleHelper)
			self[index] = su
		elsif index > BeginningGuide::LAST_GUIDE_INDEX
			self[-1]
		else
			super
		end
	end

	def player
		self[:player]
	end

	def current
		info = self.except(:player)
		curr = if info.blank?
			self[1]
		else
			i = info.keys.max
			if self[i].finished? && self[i].rewarded?
				i += 1
			end
			self[i]
		end
		check_finished(curr[:index]) if curr
		curr
	end

	def next
		i = self.except(:player).keys.max || 0
		self[i + 1]
	end

	def finish_all?
		self.except(:player).size >= BeginningGuide::LAST_GUIDE_INDEX
	end

	# New a village instance with id, no need to query redis.
	def village_with_id
		if @village_with_id.nil?
			@village_with_id = Village.new(:id => player.village_id)
		end
		@village_with_id
	end

	def check_finished(index)
		quest = self[index]

		sig = case index
		# 建造采集场
		when 1
			collecting_farm = village_with_id.buildings.find(:type => Building.hashes[:collecting_farm])
			collecting_farm.any?
		# 采集场加速完成
		when 2
			village_with_id.has_built_building?(Building.hashes[:collecting_farm])
		# 建造孵化园并加速完成
		when 3
			village_with_id.has_built_building?(Building.hashes[:habitat])
		# 孵化并加速完成
		when 4
			ret = player.guide_cache['has_hatched_dino'] && player.guide_cache['hatch_speed_up']
			ret.nil? ? false : ret
		# 建造兽栏并加速完成
		when 5
			village_with_id.has_built_building?(Building.hashes[:beastiary])
		# 喂养恐龙
		when 6
			ret = player.guide_cache['feed_dino']
			ret.nil? ? false : ret
		# 攻打野怪
		when 7
			ret = player.guide_cache['attack_monster']
			ret.nil? ? false : ret
		# 恐龙疗伤
		when 8
			ret = player.guide_cache['heal_dino']
			ret.nil? ? false : ret
		# 布防村落
		when 9
			ret = player.guide_cache['set_defense']
			ret.nil? ? false : ret
		# 建造工坊
		when 10
			village_with_id.has_built_building?(Building.hashes[:workshop])
		# 研究科技
		when 11
			ret = player.guide_cache['has_researched']
			ret.nil? ? false : ret
		# 建造神庙
		when 12
			village_with_id.has_built_building?(Building.hashes[:temple])
		# 供奉神灵
		when 13
			ret = player.guide_cache['has_worshiped']
			ret.nil? ? false : ret
		# 聘用顾问
		when 14
			ret = player.guide_cache['has_advisor']
			ret.nil? ? false : ret
		# 建造所有资源建筑
		when 15
			village_with_id.has_built_building?(Building.hashes[:lumber_mill]) &&
				village_with_id.has_built_building?(Building.hashes[:hunting_field]) &&
					village_with_id.has_built_building?(Building.hashes[:quarry])
		# 建造仓库
		when 16
			village_with_id.has_built_building?(Building.hashes[:warehouse])
		# 建造市场
		when 17
			village_with_id.has_built_building?(Building.hashes[:market])
		else
			false
		end
		quest.finished = sig
	end

end

module BeginningGuideSingleHelper
	%w(finished rewarded).each do |name|
		define_method(name) do
			self[name.to_sym]
		end

		define_method("#{name}?") do
			self[name.to_sym] == 1 ? true : false
		end

		define_method("#{name}=") do |sig|
			self[name.to_sym] = ((sig == true or sig == 1) ? 1 : 0)
		end
	end

	def over?
		finished? && rewarded?
	end

	def index
		self[:index]
	end

end











