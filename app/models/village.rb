class Village < GameClass
	attribute :name, 			String
	attribute :x, 				Integer
	attribute :y, 				Integer

	attribute :player_id, 	Integer
	collection :buildings, 	Building

	include Ohm::MyTimestamping

	index :name
	index :x
	index :y
	index :player_id



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

end
