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
			render_error(Error::NORMAL, "INVALID_PLAYER_ID_WHEN_APPLY_AN_ADVISOR")
			return
		end

		advisor = Player.new(:id => params[:player_id])
		advisor.gets(:is_advisor, :is_hired, :player_type)

		if !advisor.is_npc? && advisor.is_advisor && advisor.is_hired
			render_error(Error::NORMAL, I18n.t('advisors_error.already_an_advisor'))
			return
		end

		if Advisor.create_by_type_and_days(params[:player_id], params[:type], params[:days])
			advisor.get(:serial_tasks_data)
			advisor.serial_tasks_data[:being_advisor] ||= 0
			advisor.serial_tasks_data[:being_advisor] += 1
			advisor.set :serial_tasks_data, advisor.serial_tasks_data
			
			render :json => {:message => Error.success_message}
		else
			render_error(Error::NORMAL, "UNKNOWN_ERROR_WHEN_APPLY_AN_ADVISOR")
		end

	end

	# 聘用顾问
	def hire
		if params[:employer_id].to_i == params[:advisor_id].to_i
			render_error(Error::NORMAL, I18n.t('advisors_error.cannot_hire_yourself'))
			return
		end

		is_adv, is_hired = Player.gets(params[:advisor_id], :is_advisor, :is_hired)

		# adv_info:
		# => [name, level, days, avatar_id]
		adv_info = Advisor.get(params[:type], params[:advisor_id])
		advisor = Player.new(:id => params[:advisor_id])
		advisor.gets(:player_type)
		err = ''

		if !advisor.is_npc?
			if is_adv.to_i == 0 || adv_info.blank?
				err = I18n.t('advisors_error.advisor_not_exist')
			elsif is_hired.to_i == 1
				err = I18n.t('advisors_error.has_hired')
			end
		end

		if not err.empty?
			render_error(Error::NORMAL, err) and	return
		end

		employer = Player[params[:employer_id]]

		if employer.spend!(:gold_coin => adv_info[:price])
			Advisor.employ!(params[:employer_id], params[:advisor_id], params[:type], adv_info[:days])

			if !employer.beginning_guide_finished && !employer.guide_cache[:has_advisor]
				cache = employer.guide_cache.merge(:has_advisor => true)
				employer.set :guide_cache, cache
			end

			if employer.has_beginner_guide?
				employer.cache_beginner_data(:has_hired_advisor => true)
			end

			render_success(:player => employer.to_hash(:advisors))
		else
			render_error(Error::NORMAL, I18n.t('general.not_enough_gold'))
		end
	end

	def fire
		Advisor.fire!(@player.id, params[:employer_id])
		render :json => {:player => @player.load!.to_hash(:advisors)}
	end

end
