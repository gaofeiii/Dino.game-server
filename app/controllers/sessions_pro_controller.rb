class SessionsProController < ApplicationController

	before_filter :get_device_token, :only => [:demo, :create]
	skip_filter :check_server_status, :only => [:server_list]
	skip_filter :check_version, :only => [:server_list]

	def server_list
		render :json => ServerInfo.current[:server_list]
	end

	def demo
		Ohm.redis.setnx('Account:count', 100000)

		account = Account.new

		until account.save
			account.username = I18n.t('lord', :locale => 'cn') + "_" + "#{format('%06d', Ohm.redis.incr('Account:count'))}"
			account.password = String.sample(6)
		end

		player = Player.create 	:account_id 	=> account.id,
														:nickname			=> account.username,
														:device_token => @device_token

		player.login!
		render_success 	:player 				=> player.to_hash(:all),
										:is_new 				=> true,
										:username 			=> account.username,
										:password 			=> account.password,
										:session_key 		=> player.session_key,
										:const_version 	=> ServerInfo.const_version
	end

	def login
		account = Account.find_by_username(params[:username])

		if account && account.authenticate(params[:password])
			player = Player.find_by_account_id(account.id)
			player.login!

			render_success 	:player 				=> player.to_hash(:all),
											:is_new 				=> false,
											:session_key 		=> player.session_key,
											:const_version 	=> ServerInfo.const_version
		else
			render_error(Error::NORMAL, I18n.t('login_error.incorrect_username_or_password'))
		end
	end

	def modify_nickname
		player = Player[params[:player_id]]

		if player
			player.update :nickname => params[:nickname]
			player.account.update_attributes :username => params[:nickname]
			render_success(:player => {:nickname => player.nickname}, :username => player.nickname)
		else
			render_error(Error::NORMAL, "Invalid player id")
		end
	end

	def change_pass
		account = Account.find_by_username(params[:username])

		if account && account.update_attributes(:password => params[:new_pass])
			render_success(:password => params[:new_pass])
		else
			render_error(Error::NORMAL, "Invalid player name")
		end
	end

	private 
	def get_device_token
		@device_token = params[:device_token].to_s.delete('<').delete('>').delete(' ')
	end
end