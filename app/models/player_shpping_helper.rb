module PlayerShppingHelper
	module ClassMethods
		
	end
	
	module InstanceMethods
		
		# Hash value, keys are sids, value => true or false
		def first_purchase_reward
			if @attributes[:first_purchase_reward].kind_of?(Hash)
				return @attributes[:first_purchase_reward]
			end

			if @attributes[:first_purchase_reward].nil?
				return {}
			end

			h = {}
			JSON(@attributes[:first_purchase_reward]).each do |k, v|
				h[k.to_i] = v
			end
			@attributes[:first_purchase_reward] = h
			@attributes[:first_purchase_reward]
		end

		def save!
			self.first_purchase_reward = first_purchase_reward.to_json
			super
		end
	end
	
	def self.included(model)
		model.attribute :first_purchase_reward
		model.class_eval do
			remove_method :first_purchase_reward
		end

		model.extend         ClassMethods
		model.send :include, InstanceMethods
	end
end