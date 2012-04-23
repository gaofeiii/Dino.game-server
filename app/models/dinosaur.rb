class Dinosaur < GameClass
	attribute :level, 		Integer
	attribute :experience, 		Integer
	attribute :type, 			Integer

	attribute :basic_attack, 			Integer
	attribute :basic_defense, 		Integer
	attribute :basic_agility,			Integer
	attribute :total_attack, 			Integer
	attribute :total_defense, 		Integer
	attribute :total_agility,			Integer


	reference :player, 		Player
	reference :village, 	Village

	# 构造函数
	def initialize(args = {})
		super
		self.level = 1 if level.nil?
		self.experience = 0 unless experience
	end

	def to_hash
		super
	end
end
