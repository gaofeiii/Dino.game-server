class Dinosaur < Ohm::Model
	STATUS = {:egg => 0, :infancy => 1, :adult => 2}
	EVENTS = {:hatch => 1}

	include Ohm::DataTypes
	include Ohm::Callbacks
	include Ohm::Timestamps

	include OhmExtension

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

	class << self
		def info
			DINOSAURS
		end
	end


	def initialize(args = {})
		super
		self.level = 1 if level.nil?
		self.experience = 0 if experience.nil?
	end

	def info
		DINOSAURS[type]
	end

	def to_hash
		hash = {
			:id => id.to_i,
			:level => level,
			:experience => experience,
			:type => type,
			:status => status,
			:attack => total_attack,
			:defense => total_defense,
			:agility => total_agility
		}

		if event_type != 0
			hash[:event_type]  = event_type,
			hash[:start_time]  = start_time,
			hash[:finish_time] = finish_time
		end
		return hash
	end

	def hatch_speed_up!
		if event_type == EVENTS[:hatch]
			init_props
			self.level = 1
			self.status = 1
			self.event_type = 0
			self.save
		else
			false
		end
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
			else
			end
		end
		self
	end

	def update_status!
		update_status
		save
	end

	def init_props
		[:attack, :defense, :agility].each do |att|
			send("basic_#{att}=", info[:property][att])
			send("total_#{att}=", send("basic_#{att}"))
		end
	end

	protected

	# def before_save
	# 	[:attack, :defense, :agility].each do |att|
	# 		send("total_#{att}=", send("basic_#{att}"))
	# 	end
	# end

end













