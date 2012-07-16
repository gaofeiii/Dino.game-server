include SessionsHelper

class SessionsController < ApplicationController

	skip_before_filter :find_player

	def create
		# signin_url = URI("http://#{ACCOUNT_SERVER_IP}:#{ACCOUNT_SERVER_PORT}/signin")
		# res = Net::HTTP.post_form signin_url, 
		# 	:username => params[:username],
		# 	:email => params[:email],
		# 	:password => params[:password]
		# rcv_msg = JSON.parse(res.body).deep_symbolize_keys
		rcv_msg = account_authenticate :username => params[:username], 
																	 :email 	 => params[:email], 
																	 :password => params[:password]
		data = {}
		if rcv_msg[:success]
			@player = Player.find(:account_id => rcv_msg[:account_id]).first
			if @player.nil?
				@player = create_player(rcv_msg[:account_id])
			end
			data = {:message => "LOGIN_SUCCESS", :player => @player.to_hash}
		else
			data = {:message => "LOGIN_FAILED"}
		end
		render :json => data
	end

	# def create
	# 	player = Player.find(:account_id => params[:account_id]).first

	# 	unless player
	# 		player = create_player(params[:account_id])
	# 	end

	# 	login(player, params[:session_key])
	# 	render :json => {:player_id => player.id.to_i}
	# end
end
