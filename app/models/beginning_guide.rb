# Only included by player model.
# Require ohm, ohm-contrib gems.
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
		@attributes[:guide_info] = @attributes[:guide_info].kind_of?(Hash) ? @attributes[:guide_info] : JSON.parse(@attributes[:guide_info] || "{}")
		@attributes[:guide_info].keys.each do |key|
			@attributes[:guide_info][(key.to_i rescue key) || key] = @attributes[:guide_info].delete(key).extend(BeginningGuideHelper)
		end
		@attributes[:guide_info]
	end
	
end

module BeginningGuideHelper
	
end
