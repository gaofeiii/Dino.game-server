module PlayerTechHelper
	module ClassMethods
		
	end
	
	module InstanceMethods
		# Define all tech methods like: player.tech_lumbering
		# Techs:
		# ["residential", "lumbering", "mining", "hunting", "farming", "storing", 
		#  "hatching", "raising", "trading", "researching", "worshipping", "alchemy", 
		#  "courage", "fortitude", "loyalty", "mercy", "discovery", "violence", "plunder", 
		#  "wisdom"] 
		Technology.names.each do |tech_name|
			define_method("tech_#{tech_name}") do
				self.technologies.find(:type => Technology.hashes[tech_name.to_sym]).first
			end
		end

		# 住宅
		def tech_worker_number
			tech = tech_residential
			return tech.nil? ? 1 : tech.property[:worker_num]
		end

		def tech_house_max
			tech = tech_residential
			return tech.nil? ? 1 : tech.property[:house_max]
		end

		# 伐木技术
		def tech_produce_wood_rate #(number/hour)
			tech = tech_lumbering
			return tech.nil? ? Technology.const[2][0][:property][:wood_inc] : tech.property[:wood_inc]
		end

		# 采石技术
		def tech_produce_stone_rate
			tech = tech_mining
			tech.nil? ? Technology.const[3][0][:property][:stone_inc] : tech.property[:stone_inc]
		end

		# 狩猎技术
		def tech_produce_meat_rate
			tech = tech_hunting
			tech.nil? ? Technology.const[4][0][:property][:meat_inc] : tech.property[:meat_inc]
		end

		# 采集技术
		def tech_produce_fruit_rate
			tech = tech_farming
			tech.nil? ? Technology.const[5][0][:property][:fruit_inc] : tech.property[:fruit_inc]
		end

		# 储藏技术
		def tech_warehouse_size
			tech = tech_storing
			tech.nil? ? Technology.const[6][0][:property][:resource_max] : tech.property[:resource_max]
		end

		# 孵化技术
		def tech_eggs_size
			tech = tech_hatching
			tech.nil? ? Technology.const[7][0][:property][:eggs_max] : tech.property[:eggs_max]
		end

		# 孵化效率增加
		def tech_hatching_inc
			tech = tech_hatching
			tech.nil? ? Technology.const[7][0][:property][:hatch_efficiency] : tech.property[:hatch_efficiency]
		end

		# 驯养
		def tech_dinosaurs_size
			tech = tech_raising
			tech.nil? ? Technology.const[8][0][:property][:dinosaur_max] : tech.property[:dinosaur_max]
		end

		# 商业
		def tech_transport_effeciency
			tech = tech_trading
			tech.nil? ? Technology.const[9][0][:property][:transport_effeciency] : tech.property[:transport_effeciency]
		end

		# 科研
		def tech_research_inc
			tech = tech_researching
			tech.nil? ? Technology.const[10][0][:property][:research_effectiency] : tech.property[:research_effectiency]
		end

		# 祭祀
		def tech_praying_inc
			tech = tech_worshipping
			tech.nil? ? Technology.const[11][0][:property][:pray_effectiency] : tech.property[:pray_effectiency]
		end

		# 炼金
		def tech_gold_inc
			tech = tech_alchemy
			tech.nil? ? Technology.const[12][0][:property][:extra_gold] : tech.property[:extra_gold]
		end

		# 勇气
		def tech_attack_inc
			tech = tech_courage
			tech.nil? ? Technology.const[13][0][:property][:attack_inc] : tech.property[:attack_inc]
		end

		# 刚毅
		def tech_defense_inc
			tech = tech_fortitude
			tech.nil? ? Technology.const[14][0][:property][:defense_inc] : tech.property[:defense_inc]
		end

		# 忠诚
		def tech_hp_inc
			tech = tech_loyalty
			tech.nil? ? Technology.const[15][0][:property][:hp_inc] : tech.property[:hp_inc]
		end

		# 仁义

		def tech_skill_chance_inc
			tech = tech_mercy
			tech.nil? ? Technology.const[16][0][:property][:trigger_inc] : tech.property[:trigger_inc]
		end

		# 寻宝
		def tech_egg_discovery_inc
			tech = tech_discovery
			tech.nil? ? Technology.const[17][0][:property][:eggfall] : tech.property[:eggfall]
		end

		# 残暴
		def tech_damage_inc
			tech = tech_violence
			tech.nil? ? Technology.const[18][0][:property][:damage_inc] : tech.property[:damage_inc]
		end

		# 掠夺
		def tech_plunder_inc
			tech = tech_plunder
			tech.nil? ? Technology.const[19][0][:property][:plunder] : tech.property[:plunder]
		end

		# 智慧
		def tech_xp_inc
			tech = tech_wisdom
			tech.nil? ? Technology.const[20][0][:property][:xp_inc] : tech.property[:xp_inc]
		end

	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end