# encoding: utf-8

module MonsterConst
	module ClassMethods
		@@monster_const = Hash.new
		@@monster_reward = Hash.new

		def const
			if @@monster_const.blank?
				load_const!
			end
			@@monster_const
		end

		def rewards
			if @@monster_reward.blank?
				load_const!
			end
			@@monster_reward
		end

		def load_const!
			@@monster_const.clear
			book = Roo::Excelx.new("#{Rails.root}/const/monsters.xlsx")

			book.default_sheet = '野怪数值'

			3.upto(book.last_row) do |i|
				lvl = book.cell(i, 'A').to_i
				hp = book.cell(i, 'B').to_i
				attack = book.cell(i, 'C').to_f
				defense = book.cell(i, 'd').to_f
				speed = book.cell(i, 'e').to_f
				xp = book.cell(i, 'm').to_i

				@@monster_const[lvl] = {
					:level => lvl,
					:hp => hp,
					:attack => attack,
					:defense => defense,
					:agility => speed,
					:xp => xp
				}
			end

			book.default_sheet = "野怪组合列表"

			4.upto(book.last_row) do |i|
				type = book.cell(i, 'A').to_i
				monster_number = book.cell(i, 'C').to_i
				food_count = book.cell(i, 'D').to_i
				res_count = book.cell(i, 'E').to_i
				egg_type = book.cell(i, 'F').to_s.split(',').map(&:to_i)
				scrl_type = book.cell(i, 'G').to_s.split(',').map(&:to_i)
				@@monster_reward[type] = {
					:type => type,
					:monster_number => monster_number,
					:food_count => food_count,
					:res_count => res_count,
					:egg_type => egg_type,
					:scroll_type => scrl_type
				}
			end
		end # End of load_const!

		def get_monster_level_and_number_by_type(m_type)
			case m_type
			when 1
				[1, 1]
			when 2
				[rand(1..3), 2]
			when 3
				[rand(3..5), 2]
			when 4
				[rand(5..8), 3]
			when 5
				[rand(8..10), 3]
			when 6
				[rand(10..15), 3]
			when 7
				[rand(15..20), 4]
			when 8
				[rand(20..25), 4]
			when 9
				[rand(25..30), 4]
			when 10
				[rand(30..35), 4]
			when 11..19
				[rand(((m_type - 4) * 5)..((m_type - 3) * 5)), 5]
			when 20
				[80, 5]
			end
		end
	end
	
	module InstanceMethods
		def info
			self.class.const[self.level]
		end

		def xp
			info[:xp]
		end

	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end