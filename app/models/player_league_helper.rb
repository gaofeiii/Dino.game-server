module PlayerLeagueHelper
	
	module ClassMethods
		
	end
	
	module InstanceMethods
		def in_league?
			!league_id.blank?
		end

		def can_get_league_gold
			@league = League.new(:id => league_id)

			if !@league.exists?
				return 0
			else
				return @league.harvest_gold
			end
		end

		def league_member_ship
			LeagueMemberShip[league_member_ship_id]
		end
	end
	
	def self.included(model)
		model.attribute 	:league_member_ship_id
		model.collection 	:league_applys, 				LeagueApply

		model.extend         ClassMethods
		model.send :include, InstanceMethods
	end
end