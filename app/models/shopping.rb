class Shopping

	include ShoppingConst

	class << self

		def find_gems_count_by_product_id(product_id)
			self.list[:gems].each do |itm|
				return itm[:count] if itm[:product_id] == product_id
			end
		end
		
	end

end