# encoding: utf-8

module ShoppingConst
	GOODS_TYPE = {
		:res 	=> 1,
		:item => 2,
		:egg 	=> 3
	}


	module ClassMethods
		
		@@all_goods = Hash.new
		@@all_goods_hash = Hash.new
		@@goods_desc = Hash.new

		@@eggs_drops = {}

		@@first_time_rewards = {
			1001 => {:gold => 100000 },
			1002 => {:items => [{:item_cat => 1, :item_type => 9, :item_count => 1, :quality => 1}]},
			1003 => {:items => [{:item_cat => 1, :item_type => 9, :item_count => 1, :quality => 2}]},
			1004 => {:items => [{:item_cat => 1, :item_type => 9, :item_count => 1, :quality => 3},
													{:item_cat => 1, :item_type => 8, :item_count => 1, :quality => 3}]},
			1005 => {:items => [{:item_cat => 1, :item_type => 9, :item_count => 1, :quality => 4}]},
		}

		def first_time_rewards
			@@first_time_rewards
		end

		def const
			if @@all_goods.blank?
				reload!
			end
			@@all_goods
		end
		alias list const

		def hashes
			if @@all_goods_hash.blank?
				reload!
			end
			@@all_goods_hash
		end

		def descs
			if @@goods_desc.blank?
				reload!
			end
			@@goods_desc
		end

		def eggs_drops
			if @@eggs_drops.blank?
				reload!
			end
			@@eggs_drops
		end

		def reload!
			@@all_goods = {
				:gems => [],
				:gold => [],
				:resources => [],
				:eggs => [],
				:scrolls => [],
				:food => [],
				:vip => [],
				:protection => [],
				:lottery => []

			}
			@@all_goods_hash.clear

			book = Roo::Excelx.new("#{Rails.root}/const/shopping_list.xlsx")

			book.default_sheet = "宝石"
			2.upto(book.last_row).each do |i|
				sid = book.cell(i, 'C').to_i
				count = book.cell(i, 'D').to_i
				product_id = book.cell(i, 'E')
				reference_name = book.cell(i,'F')
				usd_price = book.cell(i, 'G').to_f
				cny_price = book.cell(i, 'H').to_f
				cn_desc = book.cell(i, 'M')
				en_desc = book.cell(i, 'N')

				@@goods_desc[sid] = {
					:cn => cn_desc,
					:en => en_desc
				}

				@@all_goods[:gems] << {
					:sid => sid,
					:count => count,
					:product_id => product_id,
					:reference_name => reference_name,
					:price => usd_price,
					:goods_type => 2
				}
			end

			book.default_sheet = "资源"
			2.upto(book.last_row) do |i|
				name = book.cell(i, 'B')
				sid = book.cell(i, 'C').to_i
				count = book.cell(i, 'e').to_i
				gem_price = book.cell(i, 'f').to_i
				res_type = book.cell(i, 'g').to_i

				record = {:sid => sid, :count => count, :type => res_type, :gem => gem_price}
				if name == "金币"
					@@all_goods[:gold] << record
					@@all_goods_hash[sid] = {:goods_type => GOODS_TYPE[:res], :res_type => :gold,:count => count, :gems => gem_price}
				else
					@@all_goods[:resources] << record
					if name == "石料"
						@@all_goods_hash[sid] = {:goods_type => GOODS_TYPE[:res], :res_type => :stone,:count => count, :gems => gem_price}
					else # if name == "木材"
						@@all_goods_hash[sid] = {:goods_type => GOODS_TYPE[:res], :res_type => :wood,:count => count, :gems => gem_price}
					end
				end
			end

			book.default_sheet = "道具"
			3.upto(book.last_row) do |i|
				name = book.cell(i, 'B')
				sid = book.cell(i, 'C').to_i
				count = book.cell(i, 'D').to_i
				gem_price = book.cell(i, 'E').to_i
				gold_price = book.cell(i, 'F').to_i
				item_cat = book.cell(i, 'G').to_i
				item_type = book.cell(i, 'H').to_i
				cn_desc = book.cell(i, 'I').to_s
				en_desc = book.cell(i, 'J').to_s

				record = {:sid => sid, :count => count, :gold => gold_price, :gem => gem_price, :cat => item_cat, :type => item_type}
				goods_type = case name
				when "恐龙蛋"
					# 读取恐龙蛋概率信息
					quality_odds = ('K'..'O').to_a.map { |column| book.cell(i, column).to_f }
					egg_types_odds = ('Q'..'Y').to_a.map { |column|	book.cell(i, column).to_f }
					@@eggs_drops[sid] = {
						:quality_odds => quality_odds,
						:egg_types_odds => egg_types_odds
					}

					@@all_goods[:eggs] << record
					GOODS_TYPE[:egg]
				when "卷轴"
					@@all_goods[:scrolls] << record
					GOODS_TYPE[:item]
				when "食物"
					@@all_goods[:food] << record
					GOODS_TYPE[:item]
				end
				@@all_goods_hash[sid] = {
					:goods_type => goods_type,
					:item_type => item_type, 
					:item_category => item_cat,
					:gems => gem_price,
					:gold => gold_price,
					:count => count
				}

				if !en_desc.empty? && !cn_desc.empty?
					@@goods_desc[sid] = {	:en => en_desc,	:cn => cn_desc }
				end
				
			end

			book.default_sheet = '其他'
			2.upto(book.last_row) do |i|
				name = book.cell(i, 'b')
				key_name = case name
				when 'VIP'
					:vip
				when '保护'
					:protection
				when /奖券/
					:lottery
				end
				sid = book.cell(i, 'c').to_i
				count = book.cell(i, 'd').to_i
				price = book.cell(i, 'e').to_i
				item_cat = book.cell(i, 'f').to_i
				item_type = book.cell(i, 'g').to_i
				cn_desc = book.cell(i, 'h')
				en_desc = book.cell(i, 'i')

				@@all_goods[key_name] << {
					:sid => sid,
					:goods_type => GOODS_TYPE[:item],
					:item_category => item_cat,
					:item_type => item_type,
					:gems => price,
					:count => count,
				}
				@@all_goods_hash[sid] = {
					:goods_type => GOODS_TYPE[:item],
					:item_category => item_cat,
					:item_type => item_type,
					:gems => price,
					:count => count,
				}
				@@goods_desc[sid] = {
					:cn => cn_desc,
					:en => en_desc
				}
			end
			@@all_goods		
		end # End of reload!

		def find_by_sid(sid)
			self.hashes[sid]
		end # End of find_by_sid

		def find_desc_by_sid(sid)
			self.descs[sid]
		end
	end
	
	module InstanceMethods
		
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end