class AdvisorsController < ApplicationController

	before_filter :validate_player, :only => [:apply, :fire]

	# 顾问列表
	def advisor_list
		render_success :advisors => AdvisorRecord.list(:type => params[:type].to_i)
	end

	# 申请成为顾问
	def apply
		adv_relation = @player.advisor_relation

		if adv_relation
			render_error(Error::NORMAL, I18n.t('advisors_error.already_an_advisor')) and return
		end

		record = @player.advisor_record

		price = 1000

		if record.nil?
			record = AdvisorRecord.create :player_id => @player.id, :type => params[:type], :price => price#params[:price]
		else
			record.update :type => params[:type]
		end

		render_success
	end

	# 聘用顾问
	def hire
		@player = Player[params[:employer_id]]

		render_error(Error::NORMAL, "INVALID_PLAYER_ID") and return unless @player

		record = AdvisorRecord.find_by_player_id(params[:advisor_id])

		render_error(Error::NORMAL, 'advisors_error.advisor_not_exist_or_has_been_hired') unless record

		if @player.spend!(:gold => record.price)
			AdvisorRelation.create :type => record.type, :advisor_id => record.player_id, :employer_id => @player.id, :price => record.price
			record.delete
		else
			render_error(Error::NORMAL, I18n.t('general.not_enough_gold')) and return
		end

		render_success :player => @player.to_hash(:advisors)
	end

	def fire
		render_success
	end

end
