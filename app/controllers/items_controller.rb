class ItemsController < ApplicationController
	before_filter :validate_player
	before_filter :validate_item, :only => [:use]

	def my_items_list
		render :json => {:player => {:items => @player.items.map{|item| item.to_hash}}}
	end

	def use
		obj = @item.use!
		render :json => {:player => @player.to_hash(:dinosaurs)}
	end
end
