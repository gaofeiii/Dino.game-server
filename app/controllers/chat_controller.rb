class ChatController < ApplicationController

	def world_chat
		last_id = params[:last_id].to_i == -1 ? nil : params[:last_id]
		msgs = ChatMessage.world_messages(last_id, 10)
		render :json => msgs
	end

	def create_chat_message
		speaker, player_id, content, channel = params[:speaker], params[:player_id], params[:content], params[:channel].to_i

		unless channel.in?([1, 2, 3])
			render :json => {:message => "INVALID_CHANNEL"} and return
		end


		chat = ChatMessage.new 	:channel => channel, 
														:content => content,
														:player_id => player_id
		chat.to_player_id = params[:to_player_id]
		chat.save
		msgs = ChatMessage.world_messages(nil, 10)
		render :json => msgs
	end
end
