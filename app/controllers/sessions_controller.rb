include SessionsHelper

class SessionsController < ApplicationController

	skip_before_filter :find_player


	# TODO:
	# 试玩
	def demo
		
	end

	# 登录
	def create
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

	
	# 注册
	def register
		
	end

	# 登出
	def logout
		
	end

	# 更新账号
	def update
		
	end


	private

	def create_player(account_id, nickname = nil)
		n_name = nickname.nil? ? "Player_#{Digest::MD5.hexdigest(Time.now.utc.to_s + String.sample(6))}" : nickname
		Player.create :account_id => account_id, :nickname => n_name
	end


end
