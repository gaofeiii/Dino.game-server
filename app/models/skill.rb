class Skill < Ohm::Model	
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension

	include SkillConst

	attribute :type, 		Type::Integer
	attribute :level,		Type::Integer

	reference :dinosaur, 		Dinosaur
	reference :monster, 		Monster

	index :type
	index :level

	def to_hash
		{
			:type => type,
			:level => level
		}
	end

end
