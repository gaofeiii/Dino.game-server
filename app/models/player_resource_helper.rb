# Only included by Player model.

module PlayerResourceHelper
	module ClassMethods
		
	end
	
	module InstanceMethods

		def resources
			{
				:wood => wood,
				:stone => stone,
				:gold_coin => gold_coin,
				:gems => gems
			}
		end

		# playe.spend!(:wood => 100, :gold => 100, :gem => 10)
		def spend!(args = {})
			args_dup = args.dup
			args_dup[:gold_coin] = args[:gold] if args[:gold]
			args_dup[:gems] = args[:gem] if args[:gem]

			db.multi do |t|
				args_dup.symbolize_keys.each do |att, val|
					if att.in?([:gold_coin, :gems, :wood, :stone])
						return false if send(att) < val || val < 0
						t.hincrby(key, att, -val)
					end
				end
			end

			self.wood 			= wood 			- args_dup[:wood] 			if args_dup[:wood]
			self.stone 			= stone 		- args_dup[:stone] 			if args_dup[:stone]
			self.gold_coin 	= gold_coin - args_dup[:gold_coin] 	if args_dup[:gold_coin]
			self.gems 			= gems 			- args_dup[:gems] 			if args_dup[:gems]
			self
		end

		# playe.spend!(:wood => 100, :gold => 100, :gem => 10)
		def receive!(args = {})
			args_dup = args.dup
			args_dup[:gold_coin] = args[:gold] if args[:gold]
			args_dup[:gems] = args[:gem] if args[:gem]

			db.multi do |t|
				args_dup.symbolize_keys.each do |att, val|
					if att.in?([:gold_coin, :gems, :wood, :stone])
						return false if val < 0
						t.hincrby(key, att, val)
					end
				end
			end
			
			self.wood = wood + args_dup[:wood] if args_dup[:wood]
			self.stone = stone + args_dup[:stone] if args_dup[:stone]
			self.gold_coin = gold_coin + args_dup[:gold_coin] if args_dup[:gold_coin]
			self.gems = gems + args_dup[:gems] if args_dup[:gems]
			self
		end
	end
	
	def self.included(model)
		model.attribute :gems,					Ohm::DataTypes::Type::Integer
		model.attribute :gold_coin, 		Ohm::DataTypes::Type::Integer
		model.attribute :wood,					Ohm::DataTypes::Type::Integer
		model.attribute :stone, 				Ohm::DataTypes::Type::Integer

		model.extend         ClassMethods
		model.send :include, InstanceMethods
	end
end