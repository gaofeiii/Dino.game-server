# Only included by Player model.

module PlayerAdvisorHelper
	module ClassMethods
		
	end
	
	module InstanceMethods

		def delete
			super
			my_advisor.union(:advisor_id => id).each do |adv_rel|
				adv_rel.delete
			end
		end
		
		# The advisor is myself.
		def advisor_info
			{
				:id => id.to_i,
				:nickname => nickname,
				:level => level
			}
		end

		def my_advisor
			AdviseRelation.find(:employer_id => id)
		end

		def my_advisors_info
			my_advisor.map do |ar|
				ar.to_hash
			end
		end

		# Define methods: adv_inc_resource, adv_inc_damage...
		{ :produce 		=> "inc_resource",
			:military 	=> "inc_damage",
			:technology => "inc_research",
			:business 	=> "inc_business"
		}.each do |k, v|
			define_method("adv_#{v}") do
				adv = my_advisor.find(:type => Advisor::TYPES[k]).first
				adv.nil? ? 0 : adv.effect_value
			end
		end

	end
	
	def self.included(model)
		model.attribute 	:advisor_type, 			Ohm::DataTypes::Type::Integer
		model.attribute 	:is_advisor,				Ohm::DataTypes::Type::Boolean
		model.attribute 	:is_hired,					Ohm::DataTypes::Type::Boolean
		model.collection 	:advise_relations, 	AdviseRelation

		model.extend         ClassMethods
		model.send :include, InstanceMethods
	end
end