class Country < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Callbacks
	include CountryDataHelper
	include OhmExtension

	attribute :index, Type::Integer
	unique :index

	def refresh_monsters
		
	end

	def create_gold_mines
		self.gold_mine_info.each do |idx, map_type|
			x = idx / COORD_TRANS_FACTOR
			y = idx % COORD_TRANS_FACTOR

			if GoldMine.find(:x => x, :y => y).blank?
				GoldMine.create(:x => x, :y => y, :level => rand(1..2))
			end
		end

		self.hl_gold_mine_info.each do |idx, map_type|
			x = idx / COORD_TRANS_FACTOR
			y = idx % COORD_TRANS_FACTOR

			if GoldMine.find(:x => x, :y => y).blank?
				GoldMine.create(:x => x, :y => y, :level => 3)
			end
		end
	end


	protected

	def after_delete
		# Clear up town and gold indices info.
		self.clear!
	end

end
