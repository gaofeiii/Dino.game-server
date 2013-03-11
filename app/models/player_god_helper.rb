module PlayerGodHelper
	GOD_TRIGGER_CHANCE = 0.05
	module ClassMethods
		
	end
	
	module InstanceMethods
		
		def save!
			self.god_taken_effect_time = ::Time.now.to_i if god_taken_effect_time.zero?
			super
		end

		def curr_god
			if @curr_god.nil?
				@curr_god = gods.first
			end
			@curr_god
		end

		def refresh_god_status!
			if self.god_taken_effect_time < Time.now.beginning_of_day.to_i
				self.set :god_taken_effect, 0
			end
		end

		def trigger_god_effect
			if Tool.rate(GOD_TRIGGER_CHANCE)
				case curr_god.type
				when God.hashes[:argriculture]
					res = ['wood', 'stone'].sample
					self.set res, self.tech_warehouse_size
					Mail.create :mail_type => Mail::TYPE[:system],
											:sys_mail_type => Mail::SYS_TYPE[:normal],
											:receiver_name => self.nickname,
											:sender_name => I18n.t(:system, :locale => self.locale),
											:title => I18n.t("god_effect_mail.argriculture.title"),
											:content => I18n.t("god_effect_mail.argriculture.content", :res_name => I18n.t("resource.#{res}"))
					1
				when God.hashes[:business]
					Mail.create :mail_type => Mail::TYPE[:system],
											:sys_mail_type => Mail::SYS_TYPE[:normal],
											:receiver_name => self.nickname,
											:sender_name => I18n.t(:system, :locale => self.locale),
											:title => I18n.t("god_effect_mail.business.title"),
											:content => I18n.t("god_effect_mail.business.content")
					1
				when God.hashes[:war]
					Mail.create :mail_type => Mail::TYPE[:system],
											:sys_mail_type => Mail::SYS_TYPE[:normal],
											:receiver_name => self.nickname,
											:sender_name => I18n.t(:system, :locale => self.locale),
											:title => I18n.t("god_effect_mail.war.title"),
											:content => I18n.t("god_effect_mail.war.content")
					1
				when God.hashes[:intelligence]
					val = 0.2
					Mail.create :mail_type => Mail::TYPE[:system],
											:sys_mail_type => Mail::SYS_TYPE[:normal],
											:receiver_name => self.nickname,
											:sender_name => I18n.t(:system, :locale => self.locale),
											:title => I18n.t("god_effect_mail.intelligence.title"),
											:content => I18n.t('god_effect_mail.intelligence.content', :time_reduce => val.to_percentage)
					val
				else
					0
				end
			else
				0
			end
		end

	end
	
	def self.included(model)
		model.attribute 	:god_taken_effect, 			Ohm::DataTypes::Type::Boolean
		model.attribute 	:god_taken_effect_time, Ohm::DataTypes::Type::Integer
		model.collection 	:gods, 									God

		model.extend         ClassMethods
		model.send :include, InstanceMethods
	end
end