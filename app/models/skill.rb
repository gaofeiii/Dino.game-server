class Skill < Ohm::Model	
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension

	attribute :type, 		Type::Integer
	attribute :level,		Type::Integer

	reference :dinosaur, 		Dinosaur

	index :type
	index :level

	def trigger_chance
		0
	end
end
