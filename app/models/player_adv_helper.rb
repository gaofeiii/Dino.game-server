module PlayerAdvHelper
	module ClassMethods
		
	end
	
	module InstanceMethods
		
		def advisor_relation
			AdvisorRelation[advisor_relation_id]
		end

		def advisor_record
			AdvisorRecord[advisor_record_id]
		end

		def my_advisors
			advisor_relations
		end

		def advisor_dinosaur
			military_advisor_relation = my_advisors.find(:type => 2).first

			if military_advisor_relation
				military_advisor = military_advisor_relation.advisor
				military_advisor.max_level_dinosaur
			end
		end
	end
	
	def self.included(model)
		model.attribute		:advisor_relation_id,	Ohm::DataTypes::Type::Integer
		model.attribute		:advisor_record_id,		Ohm::DataTypes::Type::Integer
		model.collection 	:advisor_relations, 	AdvisorRelation, :employer

		model.extend         ClassMethods
		model.send :include, InstanceMethods
	end
end