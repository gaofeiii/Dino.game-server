class PlayerCave < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension

	reference :player, 		Player
	collection :monsters, 	Monster, :cave

	attribute :index,											Type::Integer
	attribute :stars,											Type::Integer
	attribute :get_perfect_reward, 				Type::Boolean
	attribute :todays_count,							Type::Integer
	attribute :update_count_time,					Type::Integer

	index :index

	include PlayerCaveConst

	def defense_troops
		if monsters.blank?
			_info = self.info
			mons_level, mons_num = _info[:monster_level], _info[:monster_num]

			mons_num.times do
				Monster.create_by(:level => mons_level, :type => (1..5).to_a.sample, :cave_id => id)
			end
		end
		monsters.to_a
	end

	def name(locale:'en')
		"#{I18n.t('monster_name.cave', :locale => locale)} #{index}"
	end

	def update_cave_status
		now_time = Time.now
		if update_count_time < now_time.beginning_of_day.to_i
			self.sets :todays_count => 0, :update_count_time => now_time.to_i
		end
	end

	def all_star_rewards
		self.class.all_star_rewards[index]
	end

	protected
	def before_save
		self.update_count_time = ::Time.now.to_i
	end
end