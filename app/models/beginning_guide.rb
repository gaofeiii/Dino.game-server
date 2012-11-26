# Only included by player model.
# Require ohm, ohm-contrib gems.

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

	def self.included(model)
		model.attribute :guide_info
		model.attribute :beginning_guide_finished, Ohm::DataTypes::Type::Boolean
		model.class_eval do
			remove_method :guide_info
		end
	end
	
	def save!
		self.guide_info = self.guide_info.except(:player).to_json
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
	def receive_guide_reward
		
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

	def check_finished(index)
		quest = self[index]

		sig = case index
		when 1
			collecting_farm = player.village.buildings.find(:type => Building.hashes[:collecting_farm])
			collecting_farm.any?# && collecting_farm.max{|b| b.level if b}.try(:level).to_i >= 1
		when 2
			
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











