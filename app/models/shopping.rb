class Shopping

	include ShoppingConst

	class << self

		def find_gems_count_by_product_id(product_id)
			self.list[:gems].each do |itm|
				return itm[:count] if itm[:product_id] == product_id
			end
		end

		# args.keys => :item_type, :player_id
		def buy_random_egg(args = {})
			item_type = args[:item_type]

			egg_type = if item_type == 1
				case rand(1..10)
				when 1..4
					1
				when 5..7
					2
				when 8..9
					3
				when 10
					4
				end
			elsif item_type == 2
				case rand(1..33)
				when 1..8
					3
				when 9..15
					4
				when 16..21
					5
				when 22..26
					6
				when 27..30
					7
				when 31..33
					8
				end
			else
				nil
			end
			
			quality = if item_type == 1
				case rand(1..10000)
				when 1..3000
					1
				when 3001..6900
					2
				when 6901..8900
					3
				when 8901..9990
					4
				else
					5
				end
			elsif item_type == 2
				case rand(1..10000)
				when 1..6000
					2
				when 6001..9000
					3
				when 9001..9990
					4
				else
					5
				end
			else
				nil				
			end
			return if (egg_type & quality).nil?
			Item.create :item_category => Item.categories[:egg], 
									:item_type => egg_type, 
									:player_id => args[:player_id],
									:quality => quality
		end
		
	end

end