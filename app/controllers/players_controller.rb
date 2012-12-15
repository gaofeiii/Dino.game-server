class PlayersController < ApplicationController

	before_filter :validate_player, :only => [:refresh]

	def deny_access
		render :text => "Request denied." and return
	end

	def index
		player = Session.with(:session_key, params[:session_key]).try(:player)
		if player.nil?
			render :json => {
				:message => Error.failed_message,
				:error_type => Error.types[:normal],
				:error => Error.format_message("Player not found")
				}, :status => 999 and return
		end
		render :json => {:player => player.to_hash(:all)}
	end

	def show
		player = Player[params[:id]]
		if player.nil?
			render :json => {:error => "Player not found"}, :status => 999 and return
		end
		render :json => {:player => player.to_hash(:all)}
	end

	def refresh
		data = {:message => Error.success_message, :player => @player.to_hash(:all)}
		render :json => data
	end

	def change_avatar
		if params[:avatar_id].to_i < 0
			render :json => {
				:message => Error.failed_message,
				:error_type => Error.types[:normal],
				:error => Error.format_message("Wrong type of avatar_id")
			}
			return
		end

		if Player.exists?(params[:player_id])
			Ohm.redis.hset(Player.key[params[:player_id]], :avatar_id, params[:avatar_id])
			render :json => { :message => Error.success_message }
		else
			render :json => {
				:message => Error.failed_message,
				:error_type => Error.types[:normal],
				:error => Error.format_message("Invalid player id")
			}
		end
	end

	def my_gold_mines
		r_key = "GoldMine:indices:player_id:#{params[:player_id]}"
		result = Ohm.redis.smembers(r_key).map do |g_id|
			next unless GoldMine.exists?(g_id)

			mine = GoldMine.new :id => g_id
			mine.gets(:x, :y, :type, :level, :player_id)
			# {
			# 	:id => mine.id,
			# 	:x => mine.x,
			# 	:y => mine.y,
			# 	:level => mine.level,
			# 	:type => mine.type
			# }
			mine.to_hash
		end.compact

		render :json => {
			:message => Error.success_message,
			:gold_mines => result
		}
	end
end
