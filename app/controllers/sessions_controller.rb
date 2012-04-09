class SessionsController < ApplicationController

	# TODO: 登录和注销的功能，可能自己创建一个session的类
	def create
		render :json => "Login success"
	end

	def destroy
		render :json => "Logout success"
	end
end
