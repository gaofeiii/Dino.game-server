class AdvisorsController < ApplicationController

	before_filter :validate_player, :only => [:apply, :fire]

	# 顾问列表
	def advisor_list
		render_success :advisors => AdvisorRecord.list(:type => params[:type].to_i, :count => 20)
	end

	# 申请成为顾问
	def apply
		adv_relation = @player.advisor_relation

		if adv_relation
			render_error(Error::NORMAL, I18n.t('advisors_error.already_an_advisor')) and return
		end

		record = @player.advisor_record

		price = params[:price].to_i

		if price <= 0 || price > 999999
			render_error(Error::NORMAL, I18n.t('advisors_error.invalid_price')) and return
		end

		if record.nil?
			record = AdvisorRecord.create :player_id => @player.id, :type => params[:type], :price => price
		else
			record.update :type => params[:type], :price => price
		end

		@player.advisor_record_id = record.id

		@player.serial_tasks_data[:being_advisor] ||= 0
		@player.serial_tasks_data[:being_advisor] += 1
		@player.save

		render_success
	end

	# 聘用顾问
	def hire
		@player = Player[params[:employer_id]]

		render_error(Error::NORMAL, "INVALID_PLAYER_ID") and return unless @player

		record = AdvisorRecord.find_by_player_id(params[:advisor_id])

		render_error(Error::NORMAL, I18n.t('advisors_error.advisor_not_exist_or_has_been_hired')) and return unless record

		render_error(Error::NORMAL, I18n.t('advisors_error.cannot_hire_yourself')) and return if record.player_id == @player.id

		# if @player.my_advisors.find(:type => record.type).any?
		# 	render_error(Error::NORMAL, I18n.t('advisors_error.already_have_same_type_adv')) and return
		# end

		if @player.spend!(:gold => record.price)

			relation = @player.advisor_relations.find(:type => record.type).first

			if relation.nil?
				AdvisorRelation.create :type => record.type, :advisor_id => record.player_id, :employer_id => @player.id, :price => record.price
			else
				relation.update :employer_id => @player.id
			end
			
			record.delete if not record.is_npc

			if !@player.beginning_guide_finished && !@player.beginner_guide_data[:has_hired_advisor]
				cache = @player.beginner_guide_data.merge(:has_hired_advisor => true)
				@player.set :beginner_guide_data, cache
			end
		else
			render_error(Error::NORMAL, I18n.t('general.not_enough_gold')) and return
		end

		render_success :player => @player.to_hash(:advisors)
	end

	def fire
		render_success
	end

end
