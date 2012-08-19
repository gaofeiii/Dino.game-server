class RealTimeInfoController < ApplicationController

	before_filter :validate_player

	def refresh
		world_chat = []
		data = {
			:world_chat_messages => world_chat
		}
		render :json = data
	end
end
