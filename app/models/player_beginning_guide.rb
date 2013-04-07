module PlayerBeginningGuide
	MAX_GUIDE_INDEX = 20

	module ClassMethods
		@@beginning_guide_rewards = {}
		
		def load_guide_reward!
			@@beginning_guide_rewards = YAML::load_file("#{Rails.root}/const/beginning_guide.yml").deep_symbolize_keys
		end

		def beginning_guide_rewards
			load_guide_reward! if @@beginning_guide_rewards.blank?
			@@beginning_guide_rewards
		end

		def find_beginning_guide_reward_by_index(idx)
			return {} unless idx && idx > MAX_GUIDE_INDEX


		end
	end
	
	module InstanceMethods
		
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end