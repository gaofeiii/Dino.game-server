class RealTimeInfoController < ApplicationController

	before_filter :validate_player, :only => [:info]

	def info
		chats = ChatMessage.world_message(params[:world_chat_last_id], 10)
			+ ChatMessage.league_message(params[:league_id], params[:league_chat_last_id], 10)
			+ ChatMessage.private_message(@player.id, params[:private_chat_last_id], 10)

		data = {
			:chats => chats
		}
		render_sucess(data)
	end
end
