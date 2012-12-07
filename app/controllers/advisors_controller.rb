class AdvisorsController < ApplicationController

	before_filter :validate_player, :only => [:fire]

	# 顾问列表
	def advisor_list
		start, type = params[:page].to_i, params[:type].to_i

		advs = Advisor.find_random_by_type(type, 20)

		# advs = Advisor.find_random_by_type(1, 20)
		# advs += Advisor.find_random_by_type(2, 20)
		# advs += Advisor.find_random_by_type(3, 20)
		# advs += Advisor.find_random_by_type(4, 20)
		render :json => {
			:message => Error.success_message,
			:advisors => advs
		}
	end

	# 申请成为顾问
	def apply
		if not Player.exists?(params[:player_id])
			render :json => {
				:message => Error.failed_message,
				:error_type => Error.types[:normal],
				:error => Error.format_message("invalid player id")
			}
			return
		end

		is_adv, is_hired = Player.gets(params[:player_id], :is_advisor, :is_hired)
		if is_adv.to_i == 1 || is_hired.to_i == 1
			render :json => {
				:message => Error.failed_message,
				:error_type => Error.types[:normal],
				:error => Error.format_message("you are already an advisor")
			}
			return
		end

		if Advisor.create_by_type_and_days(params[:player_id], params[:type], params[:days])
			render :json => {:message => Error.success_message}
		else
			render :json => {
				:message => Error.failed_message,
				:error_type => Error.types[:normal],
				:error => Error.format_message("Unknown error")
			}
		end

	end

	# 聘用顾问
	def hire
		if params[:employer_id].to_i == params[:player_id].to_i
			render :json => {
				:message => Error.failed_message,
				:error_type => Error.types[:normal],
				:error => Error.format_message("cannot hire yourself")
			}
			return
		end
		
		is_adv, is_hired = Player.gets(params[:advisor_id], :is_advisor, :is_hired)

		# adv_info:
		# => [name, level, days, avatar_id]
		adv_info = Advisor.get(params[:type], params[:advisor_id])

		err = ''
		if is_adv.to_i == 0 || adv_info.blank?
			err = Error.format_message("advisor not exist")
		elsif is_hired.to_i == 1
			err = Error.format_message("advisor has been hired")
		end

		if not err.empty?
			render :json => {
				:message => Error.failed_message,
				:error_type => Error.types[:normal],
				:error => err
			}
		end

		employer = Player.new :id => params[:employer_id]
		employer.get(:gold_coin)

		if employer.spend!(:gold_coin => adv_info[:price])
			Advisor.employ!(params[:employer_id], params[:advisor_id], params[:type], adv_info[:days])
			render :json => {
				:message => Error.success_message,
				:player => employer.to_hash(:advisors)
			}
		else
			render :json => {
				:message => Error.failed_message,
				:error_type => Error.types[:normal],
				:error => Error.format_message('not enough gold')
			}
		end
	end

	def fire
		Advisor.fire!(@player.id, params[:employer_id])
		render :json => {:player => @player.to_hash(:advisors)}
	end

end
