class ChatController < ApplicationController

	def world_chat
		last_id = params[:last_id].to_i == -1 ? nil : params[:last_id]

		# wc = WorldChat.messages(:last_id => params[:world_chat_last_id], :count => 10)
		# lc = LeagueChat.messages(:league_id => params[:league_id], :last_id => params[:league_chat_last_id], :count => 10)
		# pc = PrivateChat.messages(:player_id => params[:player_id], :last_id => params[:private_chat_last_id], :count => 5)
		# msgs = wc + lc + pc
		msgs = case params[:channel].to_i
			when ChatMessage::CHANNELS[:world]
				WorldChat.messages(:last_id => params[:world_chat_last_id], :count => 10)
			when ChatMessage::CHANNELS[:league]
				LeagueChat.messages(:league_id => params[:league_id], :last_id => params[:league_chat_last_id], :count => 10)
			when ChatMessage::CHANNELS[:private]
				PrivateChat.messages(:player_id => params[:player_id], :last_id => params[:private_chat_last_id], :count => 5)			
		end
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

		if !error.empty?
			render_error(Error.types[:normal], error) and return
		end

		data = case params[:channel].to_i
		when ChatMessage::CHANNELS[:world]
			WorldChat.create 	:channel => params[:channel],
												:content => params[:content],
												:player_id => params[:player_id]
			WorldChat.messages(:last_id => params[:last_id], :count => 10)
		when ChatMessage::CHANNELS[:league]
			if !League.exists?(params[:league_id])
				render_error(Error.types[:normal], "Invalid league id") and return
			end
			LeagueChat.create :channel => params[:channel],
												:content => params[:content],
												:league_id => params[:league_id],
												:player_id => params[:player_id]
			LeagueChat.messages(:league_id => params[:league_id], :last_id => params[:last_id], :count => 10)
		when ChatMessage::CHANNELS[:private]
			p '--- private chat ---'
			if !Player.exists?(params[:listener_id])
				render_error(Error.types[:normal], "To player not exist") and return
			end
			p '--- creating message...'
			PrivateChat.create 	:channel => params[:channel],
													:content => params[:content],
													:player_id => params[:player_id],
													:listener_id => params[:listener_id]
			PrivateChat.messages(:player_id => params[:player_id], :last_id => params[:last_id], :count => 5)
		end

		# chat = ChatMessage.new 	:channel => params[:channel], 
		# 												:content => params[:content],
		# 												:player_id => params[:player_id]

		# last_id = params[:last_id].to_i == -1 ? nil : params[:last_id]
		# data = case params[:channel].to_i
		# when ChatMessage::CHANNELS[:world]
		# 	chat.save
		# 	ChatMessage.world_messages(last_id, 5)
		# when ChatMessage::CHANNELS[:league]
		# 	chat.league_id = params[:league_id]
		# 	chat.save
		# 	ChatMessage.league_messages(params[:league_id], last_id, 5)
		# when ChatMessage::CHANNELS[:private]
		# 	if not Player.exists?(params[:to_player_id])
		# 		render :json => {
		# 			:message => Error.success_message,
		# 			:error_type => Error.types[:normal],
		# 			:error => Error.format_message("to player does not exist")
		# 		}
		# 		return
		# 	end
		# 	chat.to_player_id = params[:to_player_id]
		# 	chat.save
		# 	ChatMessage.private_messages(params[:player_id], last_id, 10)
		# end

		render :json => data
	end
end
