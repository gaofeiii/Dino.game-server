class SerialTask < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension

	include BasicTask
	include SerialTaskConst
	include SerialTaskConditionHelper

	reference :player, 	Player

	def to_hash
		check!
		
		locale = player.locale
		hash = {
			:number => index,
			:finished => finished,
			:rewarded => rewarded,
			:finished_steps => finished_steps,
			:total_steps => total_steps,
			:goal => info[:desc][locale],
			:level => 1,
			:reward => to_reward
		}

		if index == 20009
			hash[:x] = 488
			hash[:y] = 498
		end
		hash
	end

	def to_reward
		rwd = {}
		const_reward = info[:reward]
		rwd[:wood] = const_reward[:wood] if const_reward[:wood].to_i > 0
		rwd[:stone] = const_reward[:stone] if const_reward[:stone].to_i > 0
		rwd[:gold_coin] = const_reward[:gold_coin] if const_reward[:gold_coin].to_i > 0
		rwd[:gems] = const_reward[:gems] if const_reward[:gems]
		rwd[:item_cat] = const_reward[:item][:item_cat] if const_reward[:item][:item_cat].to_i > 0
		rwd[:item_type] = const_reward[:item][:item_type] if const_reward[:item][:item_type].to_i > 0
		rwd[:item_count] = const_reward[:item][:item_count] if const_reward[:item][:item_count].to_i > 0
		rwd[:quality] = const_reward[:item][:quality] if const_reward[:item][:quality].to_i > 0
		rwd
	end

	def get_reward
		player.get_reward Reward.new(info[:reward])
	end

end