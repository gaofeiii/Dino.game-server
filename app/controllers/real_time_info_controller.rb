class RealTimeInfoController < ApplicationController

	skip_filter :validate_sig

	def info
		shop_list = Shopping.list
		shop_list[:vip].each{|x| x[:desc] = Shopping.find_desc_by_sid(x[:sid])[I18n.locale]}
		shop_list[:protection].each{|x| x[:desc] = Shopping.find_desc_by_sid(x[:sid])[I18n.locale]}
		shop_list[:lottery].each{|x| x[:desc] = Shopping.find_desc_by_sid(x[:sid])[I18n.locale]}
		shop_list[:scrolls].each{|x| x[:desc] = Shopping.find_desc_by_sid(x[:sid])[I18n.locale]}
		shop_list[:eggs].each{|x| x[:desc] = Shopping.find_desc_by_sid(x[:sid])[I18n.locale]}

		
		data = {
			:data => {
				:buildings => Building.cost,
				:technologies => Technology.cost,
				:guide_reward => Player.beginning_guide_reward,
				:shopping_list => shop_list,
				:dinosaurs => {:recovery_speed => 60}, # 等级*60秒
				:speed_up_info => {
					:building => 300, # 每300秒消耗1个宝石
					:tech => 300,
					:dino_hp_recovery => 30000,
					:hatch_speed_up => 300
				},
				:god_cost => {
					:wood => 1000,
					:stone => 1000,
					:gold => 1000
				},
				:lottery_reward => LuckyReward.const(1).values,
				:match_gold_cost => Player.honour_gold_cost,
				:advisor_cost => Advisor.const.values.map{|x| x[:price_per_day]},
				:league_gold_cost => 1000,
				:move_town_gems_cost => 50
			}
		}
			
		render_success(data)
	end
end
