class ChatController < ApplicationController

	def world_chat
		last_id = params[:last_id].to_i == -1 ? nil : params[:last_id]
		msgs = ChatMessage.world_messages(last_id, 10)
		render :json => msgs
	end

	def create_chat_message
		error = ""
		if not Player.exists?(params[:player_id])
			error = "Invalid player id"
		end

		if not params[:channel].to_i.in?([1, 2, 3])
			error = "Invalid channel"
		end

		if not error.empty?
			render :json => {
				:message => Error.success_message,
				:error_type => Error.types[:normal],
				:error => error
			}
			return
		end

		chat = ChatMessage.new 	:channel => params[:channel], 
														:content => params[:content],
														:player_id => params[:player_id]

		last_id = params[:last_id].to_i == -1 ? nil : params[:last_id]
		data = case params[:channel].to_i
		when ChatMessage::CHANNELS[:world]
			chat.save
			ChatMessage.world_messages(last_id, 5)
		when ChatMessage::CHANNELS[:league]
			chat.league_id = params[:league_id]
			chat.save
			ChatMessage.league_messages(params[:league_id], last_id, 5)
		when ChatMessage::CHANNELS[:private]
			if not Player.exists?(params[:to_player_id])
				render :json => {
					:message => Error.success_message,
					:error_type => Error.types[:normal],
					:error => Error.format_message("to player does not exist")
				}
				return
			end
			chat.to_player_id = params[:to_player_id]
			chat.save
			ChatMessage.private_messages(params[:player_id], params[:to_player_id], last_id, 10)
		end

		render :json => data
	end
end
