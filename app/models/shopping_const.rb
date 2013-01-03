# encoding: utf-8

module ShoppingConst
	GOODS_TYPE = {
		:res => 1,
		:item => 2
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
				:food => []
			}
			book = Excelx.new("#{Rails.root}/const/shopping_list.xlsx")

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
				count = book.cell(i, 'D').to_i
				gem_price = book.cell(i, 'E').to_i
				res_type = book.cell(i, 'F').to_i
				sid = book.cell(i, 'C').to_i

				record = {:sid => sid, :count => count, :type => res_type, :gem => gem_price}
				if name == "金币"
					@@all_goods[:gold] << record
					@@all_goods_hash[sid] = {:goods_type => GOODS_TYPE[:res], :gold_coin => count, :gems => gem_price}
				else
					@@all_goods[:resources] << record
					if name == "石料"
						@@all_goods_hash[sid] = {:goods_type => GOODS_TYPE[:res], :stone => count, :gems => gem_price}
					else
						@@all_goods_hash[sid] = {:goods_type => GOODS_TYPE[:res], :wood => count, :gems => gem_price}
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
				case name
				when "恐龙蛋"
					@@all_goods[:eggs] << record
				when "卷轴"
					@@all_goods[:scrolls] << record
				when "食物"
					@@all_goods[:food] << record
				end
				@@all_goods_hash[sid] = {
					:goods_type => GOODS_TYPE[:item], 
					:item_type => item_type, 
					:item_category => item_cat,
					:gems => gem_price,
					:count => count
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