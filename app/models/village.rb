class Village < GameClass
	attribute :name
	attribute :x, 				Integer
	attribute :y, 				Integer

	attribute :player_id, 	Integer
	attribute :country_id, 	Integer
	collection :buildings, 	Building
	collection :dinosaurs, 	Dinosaur


	index :name
	index :x
	index :y
	index :player_id
	index :country_id

	# 获取村庄所属的玩家
	def player
		Player[player_id]
	end

	# 设置村庄所属的玩家
	# 不会写到数据库中，如果要保存到数据库中，需要调用save方法
	def player=(plyr)
		self.player_id = plyr ? plyr.id : nil
		self
	end

	def create_building(building_type, level = 1, x, y)
		Building.create :type => building_type.to_i, :level => level, :village_id => id, :x => x, :y => y
	end

	def full_info
		self.to_hash.merge(:buildings => buildings.to_a, :dinosaurs => dinosaurs.to_a)
	end
end
