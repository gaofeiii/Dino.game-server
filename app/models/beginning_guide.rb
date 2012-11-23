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
	def self.included(model)
		model.attribute :guide_info
		model.class_eval do
			remove_method :guide_info
		end
	end
	
	def save!
		self.guide_info = self.guide_info.to_json
		super
	end

	def guide_info
		if @attributes[:guide_info].kind_of?(Hash)
			return @attributes[:guide_info]
		else
			@attributes[:guide_info] = @attributes[:guide_info].nil? ? {} : JSON.parse(@attributes[:guide_info])
			@attributes[:guide_info].keys.each do |key|
				@attributes[:guide_info][(key.to_i rescue key) || key] = @attributes[:guide_info].delete(key).symbolize_keys!.extend(BeginningGuideSingleHelper)
			end
			@attributes[:guide_info].extend(BeginningGuideHelper)
			return @attributes[:guide_info]
		end
	end
	
end

module BeginningGuideHelper
	def [](index)
		v = super || {:index => index, :finished => 0, :rewarded => 0}.extend(BeginningGuideSingleHelper)
		if super.blank? && index > 0
			self[index] = v
		else
			v
		end
	end

	def current_quest
		if self.blank?
			self[1]
		else
			i = keys.max
			if self[i].finished? && self[i].rewarded?
				i += 1
			end
			return self[i]
		end
	end

	def next_quest
		i = keys.max || 0
		self[i + 1]
	end

end

module BeginningGuideSingleHelper
	%w(finished rewarded).each do |name|
		ind = name == "finished" ? 0 : 1

		define_method("#{name}?") do
			self[name.to_sym] == 1 ? true : false
		end

		define_method("#{name}=") do |sig|
			self[name.to_sym] = (sig ? 1 : 0)
		end
	end
end











