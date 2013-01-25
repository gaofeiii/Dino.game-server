puts '--- Reading Specialties const ---'

module SpecialtyConst
	module ClassMethods
		@@const = Hash.new

		def const
			if @@const.blank?
				load_const!
			end
			@@const
		end

		def types
			const.keys
		end

		def names
			const.values.map{|x| x[:name]}
		end

		def load_const!
			@@const = {
				1 => {:name => :waterlemon, 		:feed_point => 1800},
				2 => {:name => :corn, 					:feed_point => 1800},
				3 => {:name => :potato, 				:feed_point => 1800},
				4 => {:name => :apple, 					:feed_point => 1800},
				5 => {:name => :fish, 					:feed_point => 3600},
				6 => {:name => :tiger, 					:feed_point => 3600},
				7 => {:name => :mammuthus, 			:feed_point => 3600},
				8 => {:name => :brachiosaurus, 	:feed_point => 3600}
			}
		end
	end
	
	module InstanceMethods
		def name
			self.class.const[type][:name]
		end

		def feed_point
			self.class.const[type][:feed_point]
		end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end