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

	  def scrolls_info
	  	all_scrolls = scrolls.to_a
	  	# all_scrolls.map { |scroll| scroll.delete if scroll.count <= 0 }
	  	all_scrolls
	  end

	  def cleanup_scrolls
	  	scrolls.map { |scroll| scroll.delete if scroll.count <= 0 }
	  end

	  def eggs
	  	items.find(:item_category => Item.categories[:egg])
	  end

	  # {:item_category => item.category, :item_type => item.type, :count => item.count}
	  def receive_scroll!(item_category: nil, item_type: nil, count: nil)
	  	return unless item_category && item_type && count && count > 0	

	  	the_scrolls = self.scrolls.find(:item_type => item_type).to_a

	  	count_left = count
	  	the_scrolls.each do |scroll|
	  		if scroll.count < 5
	  			full_inc = 5 - scroll.count
	  			count_inc = full_inc <= count_left ? full_inc : count_left
	  			scroll.increase(:count, count_inc)
	  			count_left -= count_inc

	  			break if count_left <= 0
	  		end
	  	end

	  	until count_left <= 0
	  		create_count = count_left > 5 ? 5 : count_left
	  		Item.create :item_category => item_category, :item_type => item_type, :count => create_count, :player_id => id
	  		count_left -= create_count
	  	end

	  	scrolls.map(&:count)
	  end

	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end