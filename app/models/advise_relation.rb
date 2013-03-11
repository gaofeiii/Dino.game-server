class AdviseRelation < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension

	# Advisor::TYPES = {
	# 	:produce 		=> 1, 
	# 	:military 	=> 2, 
	# 	:business 	=> 3, 
	# 	:technology => 4
	# }

	attribute :type, 				Type::Integer
	attribute :start_time, 	Type::Integer
	attribute :days,				Type::Integer

	attribute :advisor_id
	attribute :employer_id

	index :employer_id
	index :advisor_id
	index :type

	def advisor_level
		@level ||= db.hget(Player.key[advisor_id], :level).to_i
		@level
	end

	def finish_time
		start_time + days.days.to_i
	end

	def effect_value
		k = case type
		when Advisor::TYPES[:produce]
			:inc_produce
		when Advisor::TYPES[:military]
			:inc_damage
		when Advisor::TYPES[:business]
			:inc_business
		when Advisor::TYPES[:technology]
			:inc_research
		end
		Advisor.const[advisor_level][k].to_f
	end

	def to_hash
		advisor = Player.new :id => advisor_id
		advisor.gets(:level, :nickname, :avatar_id)
		left_time = start_time + days.days.to_i - ::Time.now.to_i
		left_time = left_time < 0 ? 0 : left_time
		{
			:player_id => advisor_id.to_i,
			:level => advisor.level,
			:type => type,
			:nickname => advisor.nickname,
			:avatar_id => advisor.avatar_id,
			:left_time => start_time + days.days.to_i - ::Time.now.to_i,
			:effect_value => effect_value
		}
	end

	def refresh!
		if ::Time.now.to_i >= finish_time
			self.delete
		end
	end

	def self.clean_up!
		self.all.ids.each do |r_id|
			relation = self.new :id => r_id
			relation.gets(:start_time, :days)
			relation.refresh!
		end
	end

	protected
	def after_create
		Background.add_queue(self.class, 'refresh!', finish_time + 5.seconds)
	end
end
