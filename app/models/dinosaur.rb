class Dinosaur < Ohm::Model
	STATUS = {:egg => 0, :infancy => 1, :adult => 2}
	EVENTS = {:hatch => 1}

	include Ohm::DataTypes
	include Ohm::Callbacks
	include Ohm::Timestamps

	attribute :level, 				Type::Integer
	attribute :experience, 		Type::Integer
	attribute :type, 					Type::Integer
	attribute :status, 				Type::Integer

	attribute :basic_attack, 			Type::Integer			# 基础攻击
	attribute :basic_defense, 		Type::Integer			# 基础防御
	attribute :basic_agility,			Type::Integer 		# 基础敏捷
	attribute :total_attack, 			Type::Integer
	attribute :total_defense, 		Type::Integer
	attribute :total_agility,			Type::Integer

	attribute :event_type, 		Type::Integer
	attribute :start_time, 		Type::Integer
	attribute :finish_time, 	Type::Integer


	reference :player, 		Player


	def initialize(args = {})
		super
		self.level = 1 if level.nil?
		self.experience = 0 if experience.nil?
	end

	def to_hash
		hash = {
			:level => level,
			:experience => experience,
			:type => type,
			:attack => total_attack,
			:defense => total_defense,
			:agility => total_agility
		}

		if event_type != 0
			hash[:event] = {
				:event_type => event_type,
				:start_time => start_time,
				:finish_time => finish_time
			}
		end
		return hash
	end

	def update_status
		case event_type
		when 0
			return false
		when EVENTS[:hatch]
			if ::Time.now.to_i >= finish_time
				init_props
				self.level = 1
				self.status = 1
				self.event_type = 0
				return self
			end
		end
	end

	def init_props
		[:attack, :defense, :agility].each do |att|
			
		end
	end

end













