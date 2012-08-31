class Dinosaur < Ohm::Model
	STATUS = {:egg => 0, :infancy => 1, :adult => 2}
	include Ohm::DataTypes
	include Ohm::Callbacks
	include Ohm::Timestamps

	attribute :level, 				Type::Integer
	attribute :experience, 		Type::Integer
	attribute :type, 					Type::Integer

	attribute :basic_attack, 			Type::Integer			# 基础攻击
	attribute :basic_defense, 		Type::Integer			# 基础防御
	attribute :basic_agility,			Type::Integer 		# 基础敏捷
	attribute :total_attack, 			Type::Integer
	attribute :total_defense, 		Type::Integer
	attribute :total_agility,			Type::Integer


	reference :player, 		Player


	def initialize(args = {})
		super
		self.level = 1 if level.nil?
		self.experience = 0 if experience.nil?
	end

	def to_hash
		hash = {
			:level => level,
			:experience => experience,
			:type => type,
			:attack => total_attack,
			:defense => total_defense,
			:agility => total_agility
		}
	end
end
