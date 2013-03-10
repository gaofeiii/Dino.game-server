class ChatController < ApplicationController

	def world_chat
		last_id = params[:last_id].to_i == -1 ? nil : params[:last_id]

		wc = WorldChat.messages(:last_id => params[:world_chat_last_id], :count => 20)
		lc = LeagueChat.messages(:league_id => params[:league_id], :last_id => params[:league_chat_last_id], :count => 20)
		pc = PrivateChat.messages(:player_id => params[:player_id], :last_id => params[:private_chat_last_id], :count => 5)
		msgs = wc + lc + pc
		
		render :json => msgs
	end

	def create_chat_message
		error = ""
		if not Player.exists?(params[:player_id])
			error = "INVALID_PLAYER_ID"
		end

		if not params[:channel].to_i.in?([1, 2, 3])
			error = "INVALID_CHANNEL"
		end

		if !error.empty?
			render_error(Error::NORMAL, error) and return
		end

		# decoding content and filter it
		d_content = Base64.decode64(params[:content]).force_encoding("utf-8")
		d_content.filter!
		d_content = Base64.encode64 d_content

		data = case params[:channel].to_i
		when ChatMessage::CHANNELS[:world]
			WorldChat.create 	:channel => params[:channel],
												:content => d_content,
												:player_id => params[:player_id]
			WorldChat.messages(:last_id => params[:world_chat_last_id], :count => 10)
		when ChatMessage::CHANNELS[:league]
			if !League.exists?(params[:league_id])
				render_error(Error::NORMAL, "INVALID_LEAGUE_ID") and return
			end
			LeagueChat.create :channel => params[:channel],
												:content => d_content,
												:league_id => params[:league_id],
												:player_id => params[:player_id]
			LeagueChat.messages(:league_id => params[:league_id], :last_id => params[:league_chat_last_id], :count => 10)
		when ChatMessage::CHANNELS[:private]
			if !Player.exists?(params[:listener_id])
				render_error(Error::NORMAL, I18n.t('chat_error.to_player_not_exist')) and return
			end
			PrivateChat.create 	:channel => params[:channel],
													:content => d_content,
													:player_id => params[:player_id],
													:listener_id => params[:listener_id]
			PrivateChat.messages(:player_id => params[:player_id], :last_id => params[:private_chat_last_id], :count => 5)
		end


		render :json => data
	end
end
