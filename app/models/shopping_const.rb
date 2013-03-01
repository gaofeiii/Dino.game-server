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
			book = Roo::Excelx.new("#{Rails.root}/const/shopping_list.xlsx")

			book.default_sheet = "宝石"
			2.upto(book.last_row).each do |i|
				sid = book.cell(i, 'C').to_i
				count = book.cell(i, 'D').to_i
				product_id = book.cell(i, 'E')
				reference_name = book.cell(i,'F')
				usd_price = book.cell(i, 'G').to_f
				cny_price = book.cell(i, 'H').to_f

				@@all_goods[:gems] << {
					:sid => sid,
					:count => count,
					:product_id => product_id,
					:reference_name => reference_name,
					:price => usd_price
				}
			end

			book.default_sheet = "资源"
			2.upto(book.last_row) do |i|
				name = book.cell(i, 'B')
				sid = book.cell(i, 'C').to_i
				count = book.cell(i, 'D').to_f
				count_per_gem = book.cell(i, 'g').to_i
				gem_price = book.cell(i, 'E').to_i
				res_type = book.cell(i, 'F').to_i
				sid = book.cell(i, 'C').to_i

				record = {:sid => sid, :count => count, :type => res_type, :gem => gem_price, :count_per_gem => count_per_gem}
				if name == "金币"
					@@all_goods[:gold] << record
					@@all_goods_hash[sid] = {:goods_type => GOODS_TYPE[:res], :res_type => :gold,:count => count, :gems => gem_price, :count_per_gem => count_per_gem}
				else
					@@all_goods[:resources] << record
					if name == "石料"
						@@all_goods_hash[sid] = {:goods_type => GOODS_TYPE[:res], :res_type => :stone,:count => count, :gems => gem_price, :count_per_gem => count_per_gem}
					else # if name == "木材"
						@@all_goods_hash[sid] = {:goods_type => GOODS_TYPE[:res], :res_type => :wood,:count => count, :gems => gem_price, :count_per_gem => count_per_gem}
					end
				end
			end

			book.default_sheet = "道具"
			2.upto(book.last_row) do |i|
				name = book.cell(i, 'B')
				sid = book.cell(i, 'C').to_i
				count = book.cell(i, 'D').to_i
				gem_price = book.cell(i, 'E').to_i
				item_cat = book.cell(i, 'F').to_i
				item_type = book.cell(i, 'G').to_i

				record = {:sid => sid, :count => count, :gem => gem_price, :cat => item_cat, :type => item_type}
				goods_type = case name
				when "恐龙蛋"
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
					:count => count
				}
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
				desc = book.cell(i, 'h')

				@@all_goods[key_name] << {
					:sid => sid,
					:goods_type => GOODS_TYPE[:item],
					:item_category => item_cat,
					:item_type => item_type,
					:gems => price,
					:count => count,
					:desc => desc
				}
				@@all_goods_hash[sid] = {
					:goods_type => GOODS_TYPE[:item],
					:item_category => item_cat,
					:item_type => item_type,
					:gems => price,
					:count => count,
					:desc => desc
				}
			end
			@@all_goods		
		end # End of reload!

		def find_by_sid(sid)
			self.hashes[sid]
		end # End of find_by_sid
	end
	
	module InstanceMethods
		
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end