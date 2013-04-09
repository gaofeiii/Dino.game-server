module PlayerIosHelper
	module ClassMethods
		
	end
	
	module InstanceMethods
		def send_push(message)
			return if device_token.blank?
			
			send_push_message(:device_token => device_token, :message => message)
		end

		# 评论App Store检查
		def check_rating
			if !get_rating_reward && beginning_guide_finished
				self.receive!(:gems => 5)
				self.set :get_rating_reward, 1
			end
		end
	end
	
	def self.included(model)
		model.collection :app_store_orders,	AppStoreOrder
		model.extend         ClassMethods
		model.send :include, InstanceMethods
	end
end