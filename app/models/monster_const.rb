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

		def load_const!
			@@monster_const.clear
			book = Excelx.new("#{Rails.root}/const/monsters.xlsx")

			book.default_sheet = '野怪数值'

			3.upto(book.last_row) do |i|
				lvl = book.cell(i, 'A').to_i
				hp = book.cell(i, 'O').to_i
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

		end
	end
	
	module InstanceMethods
		def info
			self.class.const[self.level]
		end

		def xp
			info[:xp]
		end

		def reward
			
		end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end