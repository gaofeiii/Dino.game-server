module PlayerVipHelper
	module ClassMethods
		@@vip_login_reward = {
			:items => [
				{:item_cat => 6, :item_type => 1, :item_count => 1}
			]
		}

		def vip_login_reward
			@@vip_login_reward
		end
	end
	
	module InstanceMethods
		
		def get_vip_daily_reward
			if is_vip? && self.get_vip_login_reward_time < Time.now.beginning_of_day.to_i
				self.receive_reward!(self.class.vip_login_reward)
				self.set :get_vip_login_reward_time, Time.now.to_i
			end
		end
	end
	
	def self.included(model)
		model.attribute :get_vip_login_reward_time, 	Ohm::DataTypes::Type::Integer

		model.extend         ClassMethods
		model.send :include, InstanceMethods
	end
end