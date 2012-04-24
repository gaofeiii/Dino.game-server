# 恐龙的类

class Dinosaur < GameClass
	attribute :level, 				Integer
	attribute :experience, 		Integer
	attribute :type, 					Integer

	attribute :basic_attack, 			Integer			# 基础攻击
	attribute :basic_defense, 		Integer			# 基础防御
	attribute :basic_agility,			Integer 		# 基础敏捷
	attribute :total_attack, 			Integer
	attribute :total_defense, 		Integer
	attribute :total_agility,			Integer


	reference :player, 		Player
	reference :village, 	Village

	include Ohm::MyTimestamping

	# 构造函数
	def initialize(args = {})
		super
		self.level = 1 if level.nil?
		self.experience = 0 if experience.nil?
	end

	def to_hash
		super
	end
end
