module BattleFighter
	attr_accessor :curr_attack, :curr_defense, :curr_speed, :init_hp, :curr_hp, :total_hp, :skills, :stunned_count,
		:bleeding_count, :bleeding_val, :army, :skill_trigger_inc, :exp_inc, :is_advisor, :camp

	def curr_attack
		@curr_attack ||= self.total_attack
		@curr_attack
	end

	def curr_defense
		@curr_defense ||= self.total_defense
		@curr_defense
	end

	def speed
		curr_speed
	end

	def curr_speed
		@curr_speed ||= self.total_agility
		@curr_speed
	end

	def init_hp
		@init_hp ||= current_hp
		@init_hp
	end

	def curr_hp
		@curr_hp ||= current_hp
		@curr_hp
	end

	def total_hp
		@total_hp ||= super
		@total_hp
	end

	def skills
		@skills ||= super.to_a
		@skills
	end

	def stunned_count
		@stunned_count ||= 0
		@stunned_count
	end

	def is_stunned?
		stunned_count > 0
	end

	def is_dead?
		return curr_hp.zero?
	end

	def is_bleeding?
		bleeding_count > 0
	end

	def bleeding_count
		@bleeding_count ||= 0
		@bleeding_count
	end

	def bleeding_val
		@bleeding_val ||= 0
		@bleeding_val
	end

	def skill_trigger_inc
		@skill_trigger_inc ||= 0
		@skill_trigger_inc
	end

	def exp_inc
		@exp_inc ||= 0
		@exp_inc
	end

	def is_advisor
		@is_advisor ||= false
		@is_advisor
	end

	def camp
		@camp ||= false
		@camp
	end

	def curr_info
		hash = {
			:id => id,
			:type => type,
			:level => level,
			:quality => quality,
			:attack => curr_attack.to_i,
			:defense => curr_defense.to_i,
			:speed => curr_speed.to_i,
			:curr_hp => init_hp.to_i,
			:total_hp => total_hp.to_i,
			:name => name,
			:status => status
		}
		hash[:monster_type] = monster_type
		return hash
	end

	def monster_type
		case self.class.name
		when "Dinosaur"
			1
		when "Monster"
			2
		else
			0
		end
	end
end