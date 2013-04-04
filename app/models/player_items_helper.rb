module PlayerItemsHelper
	module ClassMethods
		
	end
	
	module InstanceMethods
		def special_items
	  	(items.find(:item_category => 4).ids + items.find(:item_category => 5).ids + items.find(:item_category => 6).ids).map do |item_id|
	  		Item[item_id]
	  	end
	  end

	  def scrolls
	  	items.find(:item_category => Item.categories[:scroll])
	  end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end