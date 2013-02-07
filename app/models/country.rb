class Country < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Callbacks
	include CountryDataHelper
	include OhmExtension

	attribute :index, Type::Integer
	unique :index

	def refresh_monsters
		db.del(creeps_info_key)
		eval("$country_#{index}_creeps_info = nil")
		refresh_creeps!
		create_monsters
	end

	def create_gold_mines
		self.gold_mine_info.each do |idx, map_type|
			x = idx % COORD_TRANS_FACTOR
			y = idx / COORD_TRANS_FACTOR

			if GoldMine.find(:x => x, :y => y).blank?
				GoldMine.create(:x => x, :y => y, :level => rand(1..2))
			end
		end

		self.hl_gold_mine_info.each do |idx, map_type|
			x = idx % COORD_TRANS_FACTOR
			y = idx / COORD_TRANS_FACTOR

			if GoldMine.find(:x => x, :y => y).blank?
				GoldMine.create(:x => x, :y => y, :level => 3)
			end
		end
	end

	def quest_monster
		code = %Q(
			if $country_#{index}_quest_monster.nil?
				$country_#{index}_quest_monster = db.smembers(self.key[:quest_monster]).map{|idx| idx.to_i}
			end
			$country_#{index}_quest_monster
		)
		eval(code)
	end

	def add_quest_monster(m_id)
		quest_monster << m_id
		db.sadd(self.key[:quest_monster], m_id)
		eval("$country_#{index}_quest_monste")
	end


	protected

	def after_delete
		# Clear up town and gold indices info.
		self.clear!
	end

end
