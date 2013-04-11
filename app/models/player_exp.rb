#encoding: utf-8

module PlayerExp
	module ClassMethods
		@@exps = Hash.new
		# @@monster_provide_exp = Hash.new
		# @@pvp_provide_exp = Hash.new
		@@battle_exp = Hash.new
		@@research_exp = Hash.new

		def load_exps!
			@@exps.clear
			# @@monster_provide_exp.clear
			# @@pvp_provide_exp.clear
			@@battle_exp.clear
			@@research_exp = Hash.new

			book = Roo::Excelx.new("#{Rails.root}/const/exps.xlsx")
			book.default_sheet = 'player_upgrade_exp'

			2.upto(book.last_row).each do |i|
				level = book.cell(i, 'A').to_i
				need_exp = book.cell(i, 'F').to_i
				@@exps[level] = need_exp
			end

			book.default_sheet = 'monster_exp'
			2.upto(book.last_row).each do |i|
				level = book.cell(i, 'A').to_i
				provide_exp = book.cell(i, 'F').to_i
				@@battle_exp[level] = provide_exp
			end

			book.default_sheet = 'research_exp'
			2.upto(book.last_row).each do |i|
				level = book.cell(i, 'A').to_i
				provide_exp = book.cell(i, 'E').to_i
				@@research_exp[level] = provide_exp
			end


			# book.default_sheet = 'monster_exp'
			# 2.upto(book.last_row).each do |i|
			# 	level = book.cell(i, 'A').to_i
			# 	provide_exp = book.cell(i, 'F').to_i
			# 	@@monster_provide_exp[level] = provide_exp
			# end
			# @@exps

			# book.default_sheet = 'pvp_exp'
			# 2.upto(book.last_row).each do |i|
			# 	level = book.cell(i, 'A').to_i
			# 	provide_exp = book.cell(i, 'F').to_i
			# 	@@pvp_provide_exp[level] = provide_exp
			# end
		end

		def all_level_exps
			if @@exps.empty?
				load_exps!
			end
			@@exps
		end

		def battle_exp
			if @@battle_exp.empty?
				load_exps!
			end
			@@battle_exp
		end

		def research_exp
			if @@research_exp.empty?
				load_exps!
			end
			@@research_exp
		end

		# def monster_provide_exp
		# 	if @@monster_provide_exp.empty?
		# 		load_exps!
		# 	end
		# 	@@monster_provide_exp
		# end

		# def pvp_provide_exp
		# 	if @@pvp_provide_exp.empty?
		# 		load_exps!
		# 	end
		# 	@@pvp_provide_exp
		# end
	end
	
	module InstanceMethods
		
		def next_level_exp
			exp = self.class.all_level_exps[self.level + 1]
			exp.nil? ? 99999999 : exp
		end

		def earn_exp!(exps = 0)
			self.experience += (exps * (1 + self.tech_xp_inc))

			if experience >= next_level_exp
				self.experience -= next_level_exp
				self.level += 1
				return self.save
			else
				return self.sets(:experience => experience)
			end
		end

		def update_level
			level_up = false

			until experience < next_level_exp
				self.experience -= next_level_exp
				self.level += 1
				level_up = true
			end

			save if level_up
		end

	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end