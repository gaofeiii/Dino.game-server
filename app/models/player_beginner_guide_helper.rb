module PlayerBeginnerGuideHelper
	module ClassMethods
		@@beginner_reward = {}
		@@cache = {}

		def beginning_guide_info
			if @@cache.empty?
				@@cache = YAML::load_file("#{Rails.root}/const/beginning_guide.yml").deep_symbolize_keys
			end
			@@cache
		end

		def beginning_guide_reward(index = nil)
			if @@beginner_reward.empty?
				@@beginner_reward = beginning_guide_info[:Reward]
			end
			
			if index.nil?
				return @@beginner_reward
			else
				return @@beginner_reward[index.to_i]
			end
		end
	end
	
	module InstanceMethods
		
		def has_built?(building_type)
			building = buildings.find(:type => building_type)
			building.any? && building.max{ |b| b.level if b }.try(:status).to_i >= 2
		end

		def find_beginner_guide_by_index(index)
			beginner_guides.find(:index => index).first
		end

		def current_guide
			all_guides_ids = beginner_guides.ids.map!(&:to_i)

			if all_guides_ids.empty?
				BeginnerGuide.create(:index => 1, :player_id => id)
			else
				last_guide = BeginnerGuide[all_guides_ids.max]

				if last_guide.rewarded
					last_guide.index >= BeginnerGuide::MAX_INDEX ? nil : BeginnerGuide.create(:index => last_guide.index + 1, :player_id => id)
				else
					last_guide
				end
			end
		end

		def has_beginner_guide?
			!beginning_guide_finished
		end

		def cache_beginner_data(data = {})
			return if data.blank?

			set :beginner_guide_data, beginner_guide_data.merge(data)
		end

	end
	
	def self.included(model)
		model.attribute :beginner_guide_data, Ohm::DataTypes::Type::SmartHash
		model.attribute :beginning_guide_finished, Ohm::DataTypes::Type::Boolean
		
		model.extend         ClassMethods
		model.send :include, InstanceMethods
	end
end