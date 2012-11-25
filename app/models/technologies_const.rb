# encoding: utf-8
module TechnologiesConst
	module ClassMethods
		@@tech_const = Hash.new
		@@tech_types = Array.new
		@@tech_names = Array.new

		%w(const types names).each do |att|
			define_method(att) do
				if eval("@@tech_#{att}").blank?
					reload!
				end
				eval("@@tech_#{att}")
			end
			
		end

		alias info const

		def reload!
			puts '--- Reading technologies const ---'
			@@tech_const.clear
			@@tech_types.clear
			@@tech_names.clear

			book = Excelx.new "#{Rails.root}/const/technologies.xlsx"

			book.default_sheet = 'define'
			definition = Hash.new

			2.upto(book.last_row).each do |i|
				number = book.cell(i, 'A').to_i
				definition[book.cell(i, 'B')] = number
				@@tech_const[number] = {}
			end

			book.default_sheet = '住宅'
			3.upto(book.last_row).each do |i|
				level = book.cell(i, 'A').to_i

				condition = {:player_level => book.cell(i, 'K').to_i}

				cost = {
					:wood => book.cell(i, 'D').to_i,
					:stone => book.cell(i, 'E').to_i,
					:gold => book.cell(i, 'F').to_i,
					:population => book.cell(i, 'G').to_i,
					:time => book.cell(i, 'H').to_i,
				}

				property = {
					:population_inc => book.cell(i, 'B').to_i,
					:population_max => book.cell(i, 'C').to_i,
				}

				reward = {
					:experience => book.cell(i, 'H').to_i,
					:score => book.cell(i, 'I').to_i,
				}

				@@tech_const[definition['住宅']][level] ||= {}
				@@tech_const[definition['住宅']][level] = {
					:condition => condition,
					:cost => cost, 
					:property => property,
					:reward => reward
				}
			end

			book.default_sheet = '伐木技术'
			3.upto(book.last_row).each do |i|
				level = book.cell(i, 'A').to_i
				condition = {:player_level => book.cell(i, 'j').to_i}
				cost = {
					:wood => book.cell(i, 'C').to_i,
					:stone => book.cell(i, 'D').to_i,
					:gold => book.cell(i, 'E').to_i,
					:time => book.cell(i, 'G').to_i,
					:population => book.cell(i, 'F').to_i
				}
				property = {
					:wood_inc => book.cell(i, 'B').to_i,
				}
				reward = {
					:experience => book.cell(i, 'h').to_i,
					:score => book.cell(i, 'i').to_i,
				}
				@@tech_const[definition['伐木']][level] ||= {}
				@@tech_const[definition['伐木']][level] = {
					:condition => condition,
					:cost => cost, 
					:property => property,
					:reward => reward
				}
			end

			book.default_sheet = '采石技术'
			3.upto(book.last_row).each do |i|
				level = book.cell(i, 'A').to_i
				condition = {:player_level => book.cell(i, 'j').to_i}
				cost = {
					:wood => book.cell(i, 'C').to_i,
					:stone => book.cell(i, 'D').to_i,
					:gold => book.cell(i, 'E').to_i,
					:population => book.cell(i, 'F').to_i,
					:time => book.cell(i, 'G').to_i,
				}
				property = {
					:stone_inc => book.cell(i, 'B').to_i,
				}
				reward = {
					:experience => book.cell(i, 'H').to_i,
					:score => book.cell(i, 'i').to_i,
				}
				@@tech_const[definition['采石']][level] ||= {}
				@@tech_const[definition['采石']][level] = {
					:condition => condition,
					:cost => cost, 
					:property => property,
					:reward => reward
				}
			end

			book.default_sheet = '狩猎技术'
			3.upto(book.last_row).each do |i|
				level = book.cell(i, 'A').to_i
				condition = {:player_level => book.cell(i, 'j').to_i}
				cost = {
					:wood => book.cell(i, 'C').to_i,
					:stone => book.cell(i, 'D').to_i,
					:gold => book.cell(i, 'E').to_i,
					:population => book.cell(i, 'F').to_i,
					:time => book.cell(i, 'G').to_i,
				}
				property = {
					:meat_inc => book.cell(i, 'B').to_i,
				}
				reward = {
					:experience => book.cell(i, 'H').to_i,
					:score => book.cell(i, 'i').to_i,
				}
				@@tech_const[definition['狩猎']][level] ||= {}
				@@tech_const[definition['狩猎']][level] = {
					:condition => condition,
					:cost => cost, 
					:property => property,
					:reward => reward
				}
			end

			book.default_sheet = '采集技术'
			3.upto(book.last_row).each do |i|
				level = book.cell(i, 'A').to_i
				condition = {:player_level => book.cell(i, 'j').to_i}
				cost = {
					:wood => book.cell(i, 'C').to_i,
					:stone => book.cell(i, 'D').to_i,
					:gold => book.cell(i, 'E').to_i,
					:population => book.cell(i, 'F').to_i,
					:time => book.cell(i, 'G').to_i,
				}
				property = {
					:fruit_inc => book.cell(i, 'B').to_i,
				}
				reward = {
					:experience => book.cell(i, 'H').to_i,
					:score => book.cell(i, 'i').to_i,
				}
				@@tech_const[definition['采集']][level] ||= {}
				@@tech_const[definition['采集']][level] = {
					:condition => condition,
					:cost => cost, 
					:property => property,
					:reward => reward
				}
			end

			book.default_sheet = '储藏技术'
			3.upto(book.last_row).each do |i|
				level = book.cell(i, 'A').to_i
				condition = {:player_level => book.cell(i, 'j').to_i}
				cost = {
					:wood => book.cell(i, 'C').to_i,
					:stone => book.cell(i, 'D').to_i,
					:gold => book.cell(i, 'E').to_i,
					:population => book.cell(i, 'F').to_i,
					:time => book.cell(i, 'G').to_i,
				}
				property = {
					:resource_max => book.cell(i, 'B').to_i,
				}
				reward = {
					:experience => book.cell(i, 'H').to_i,
					:score => book.cell(i, 'i').to_i,
				}
				@@tech_const[definition['储藏']][level] ||= {}
				@@tech_const[definition['储藏']][level] = {
					:condition => condition,
					:cost => cost, 
					:property => property,
					:reward => reward
				}
			end

			book.default_sheet = '孵化技术'
			3.upto(book.last_row).each do |i|
				level = book.cell(i, 'A').to_i
				condition = {:player_level => book.cell(i, 'l').to_i}
				cost = {
					:wood => book.cell(i, 'e').to_i,
					:stone => book.cell(i, 'f').to_i,
					:gold => book.cell(i, 'g').to_i,
					:population => book.cell(i, 'h').to_i,
					:time => book.cell(i, 'i').to_i,
				}
				property = {
					:eggs_max => book.cell(i, 'B').to_i,
					:hatch_max => book.cell(i, 'C').to_i,
					:hatch_efficiency => book.cell(i, 'd').to_i
				}
				reward = {
					:experience => book.cell(i, 'j').to_i,
					:score => book.cell(i, 'k').to_i,
				}
				@@tech_const[definition['孵化']][level] ||= {}
				@@tech_const[definition['孵化']][level] = {
					:condition => condition,
					:cost => cost, 
					:property => property,
					:reward => reward
				}
			end

			book.default_sheet = '驯养技术'
			3.upto(book.last_row).each do |i|
				level = book.cell(i, 'A').to_i
				condition = {:player_level => book.cell(i, 'k').to_i}
				cost = {
					:wood => book.cell(i, 'd').to_i,
					:stone => book.cell(i, 'e').to_i,
					:gold => book.cell(i, 'f').to_i,
					:population => book.cell(i, 'g').to_i,
					:time => book.cell(i, 'h').to_i,
				}
				property = {
					:dinosaur_max => book.cell(i, 'B').to_i,
					:training_max => book.cell(i, 'C').to_i
				}
				reward = {
					:experience => book.cell(i, 'i').to_i,
					:score => book.cell(i, 'j').to_i,
				}
				@@tech_const[definition['驯养']][level] ||= {}
				@@tech_const[definition['驯养']][level] = {
					:condition => condition,
					:cost => cost, 
					:property => property,
					:reward => reward
				}
			end

			book.default_sheet = '商业技术'
			3.upto(book.last_row).each do |i|
				level = book.cell(i, 'A').to_i
				condition = {:player_level => book.cell(i, 'k').to_i}
				cost = {
					:wood => book.cell(i, 'd').to_i,
					:stone => book.cell(i, 'e').to_i,
					:gold => book.cell(i, 'f').to_i,
					:population => book.cell(i, 'g').to_i,
					:time => book.cell(i, 'h').to_i,
				}
				property = {
					:transport_effeciency => book.cell(i, 'B').to_f,
					:tax => book.cell(i, 'C').to_f
				}
				reward = {
					:experience => book.cell(i, 'i').to_i,
					:score => book.cell(i, 'j').to_i,
				}
				@@tech_const[definition['商业']][level] ||= {}
				@@tech_const[definition['商业']][level] = {
					:condition => condition,
					:cost => cost, 
					:property => property,
					:reward => reward
				}
			end

			book.default_sheet = '科研技术'
			3.upto(book.last_row).each do |i|
				level = book.cell(i, 'A').to_i
				condition = {:player_level => book.cell(i, 'j').to_i}
				cost = {
					:wood => book.cell(i, 'C').to_i,
					:stone => book.cell(i, 'D').to_i,
					:gold => book.cell(i, 'E').to_i,
					:population => book.cell(i, 'F').to_i,
					:time => book.cell(i, 'G').to_i,
				}
				property = {
					:research_effectiency => book.cell(i, 'B').to_f,
				}
				reward = {
					:experience => book.cell(i, 'H').to_i,
					:score => book.cell(i, 'i').to_i,
				}
				@@tech_const[definition['科研']][level] ||= {}
				@@tech_const[definition['科研']][level] = {
					:condition => condition,
					:cost => cost, 
					:property => property,
					:reward => reward
				}
			end

			book.default_sheet = '祭祀技术'
			3.upto(book.last_row).each do |i|
				level = book.cell(i, 'A').to_i
				condition = {:player_level => book.cell(i, 'j').to_i}
				cost = {
					:wood => book.cell(i, 'C').to_i,
					:stone => book.cell(i, 'D').to_i,
					:gold => book.cell(i, 'E').to_i,
					:population => book.cell(i, 'F').to_i,
					:time => book.cell(i, 'G').to_i,
				}
				property = {
					:pray_effectiency => book.cell(i, 'B').to_f,
				}
				reward = {
					:experience => book.cell(i, 'H').to_i,
					:score => book.cell(i, 'i').to_i,
				}
				@@tech_const[definition['祭祀']][level] ||= {}
				@@tech_const[definition['祭祀']][level] = {
					:condition => condition,
					:cost => cost, 
					:property => property,
					:reward => reward
				}
			end


			book.default_sheet = '炼金'
			3.upto(book.last_row).each do |i|
				level = book.cell(i, 'A').to_i
				condition = {:player_level => book.cell(i, 'j').to_i}
				cost = {
					:wood => book.cell(i, 'C').to_i,
					:stone => book.cell(i, 'D').to_i,
					:gold => book.cell(i, 'E').to_i,
					:population => book.cell(i, 'F').to_i,
					:time => book.cell(i, 'G').to_i,
				}
				property = {
					:extra_gold => book.cell(i, 'B').to_f,
				}
				reward = {
					:experience => book.cell(i, 'H').to_i,
					:score => book.cell(i, 'i').to_i,
				}
				@@tech_const[definition['炼金']][level] ||= {}
				@@tech_const[definition['炼金']][level] = {
					:condition => condition,
					:cost => cost, 
					:property => property,
					:reward => reward
				}
			end

			book.default_sheet = '勇气'
			3.upto(book.last_row).each do |i|
				level = book.cell(i, 'A').to_i
				condition = {:player_level => book.cell(i, 'j').to_i}
				cost = {
					:wood => book.cell(i, 'C').to_i,
					:stone => book.cell(i, 'D').to_i,
					:gold => book.cell(i, 'E').to_i,
					:population => book.cell(i, 'F').to_i,
					:time => book.cell(i, 'G').to_i,
				}
				property = {
					:attack_inc => book.cell(i, 'B').to_f,
				}
				reward = {
					:experience => book.cell(i, 'H').to_i,
					:score => book.cell(i, 'i').to_i,
				}
				@@tech_const[definition['勇气']][level] ||= {}
				@@tech_const[definition['勇气']][level] = {
					:condition => condition,
					:cost => cost, 
					:property => property,
					:reward => reward
				}
			end

			book.default_sheet = '刚毅'
			3.upto(book.last_row).each do |i|
				level = book.cell(i, 'A').to_i
				condition = {:player_level => book.cell(i, 'j').to_i}
				cost = {
					:wood => book.cell(i, 'C').to_i,
					:stone => book.cell(i, 'D').to_i,
					:gold => book.cell(i, 'E').to_i,
					:population => book.cell(i, 'F').to_i,
					:time => book.cell(i, 'G').to_i,
				}
				property = {
					:defense_inc => book.cell(i, 'B').to_f,
				}
				reward = {
					:experience => book.cell(i, 'H').to_i,
					:score => book.cell(i, 'i').to_i,
				}
				@@tech_const[definition['刚毅']][level] ||= {}
				@@tech_const[definition['刚毅']][level] = {
					:condition => condition,
					:cost => cost, 
					:property => property,
					:reward => reward
				}
			end

			book.default_sheet = '忠诚'
			3.upto(book.last_row).each do |i|
				level = book.cell(i, 'A').to_i
				condition = {:player_level => book.cell(i, 'j').to_i}
				cost = {
					:wood => book.cell(i, 'C').to_i,
					:stone => book.cell(i, 'D').to_i,
					:gold => book.cell(i, 'E').to_i,
					:population => book.cell(i, 'F').to_i,
					:time => book.cell(i, 'G').to_i,
				}
				property = {
					:hp_inc => book.cell(i, 'B').to_f,
				}
				reward = {
					:experience => book.cell(i, 'H').to_i,
					:score => book.cell(i, 'i').to_i,
				}
				@@tech_const[definition['忠诚']][level] ||= {}
				@@tech_const[definition['忠诚']][level] = {
					:condition => condition,
					:cost => cost, 
					:property => property,
					:reward => reward
				}
			end

			book.default_sheet = '仁义'
			3.upto(book.last_row).each do |i|
				level = book.cell(i, 'A').to_i
				condition = {:player_level => book.cell(i, 'j').to_i}
				cost = {
					:wood => book.cell(i, 'C').to_i,
					:stone => book.cell(i, 'D').to_i,
					:gold => book.cell(i, 'E').to_i,
					:population => book.cell(i, 'F').to_i,
					:time => book.cell(i, 'G').to_i,
				}
				property = {
					:trigger_inc => book.cell(i, 'B').to_f,
				}
				reward = {
					:experience => book.cell(i, 'H').to_i,
					:score => book.cell(i, 'i').to_i,
				}
				@@tech_const[definition['仁义']][level] ||= {}
				@@tech_const[definition['仁义']][level] = {
					:condition => condition,
					:cost => cost, 
					:property => property,
					:reward => reward
				}
			end

			book.default_sheet = '寻宝'
			3.upto(book.last_row).each do |i|
				level = book.cell(i, 'A').to_i
				condition = {:player_level => book.cell(i, 'j').to_i}
				cost = {
					:wood => book.cell(i, 'C').to_i,
					:stone => book.cell(i, 'D').to_i,
					:gold => book.cell(i, 'E').to_i,
					:population => book.cell(i, 'F').to_i,
					:time => book.cell(i, 'G').to_i,
				}
				property = {
					:eggfall => book.cell(i, 'B').to_f,
				}
				reward = {
					:experience => book.cell(i, 'H').to_i,
					:score => book.cell(i, 'i').to_i,
				}
				@@tech_const[definition['寻宝']][level] ||= {}
				@@tech_const[definition['寻宝']][level] = {
					:condition => condition,
					:cost => cost, 
					:property => property,
					:reward => reward
				}
			end

			book.default_sheet = '残暴'
			3.upto(book.last_row).each do |i|
				level = book.cell(i, 'A').to_i
				condition = {:player_level => book.cell(i, 'j').to_i}
				cost = {
					:wood => book.cell(i, 'C').to_i,
					:stone => book.cell(i, 'D').to_i,
					:gold => book.cell(i, 'E').to_i,
					:population => book.cell(i, 'F').to_i,
					:time => book.cell(i, 'G').to_i,
				}
				property = {
					:damage_inc => book.cell(i, 'B').to_f,
				}
				reward = {
					:experience => book.cell(i, 'H').to_i,
					:score => book.cell(i, 'i').to_i,
				}
				@@tech_const[definition['残暴']][level] ||= {}
				@@tech_const[definition['残暴']][level] = {
					:condition => condition,
					:cost => cost, 
					:property => property,
					:reward => reward
				}
			end

			book.default_sheet = '掠夺'
			3.upto(book.last_row).each do |i|
				level = book.cell(i, 'A').to_i
				condition = {:player_level => book.cell(i, 'j').to_i}
				cost = {
					:wood => book.cell(i, 'C').to_i,
					:stone => book.cell(i, 'D').to_i,
					:gold => book.cell(i, 'E').to_i,
					:population => book.cell(i, 'F').to_i,
					:time => book.cell(i, 'G').to_i,
				}
				property = {
					:plunder => book.cell(i, 'B').to_f,
				}
				reward = {
					:experience => book.cell(i, 'H').to_i,
					:score => book.cell(i, 'i').to_i,
				}
				@@tech_const[definition['掠夺']][level] ||= {}
				@@tech_const[definition['掠夺']][level] = {
					:condition => condition,
					:cost => cost,
					:property => property,
					:reward => reward
				}
			end

			book.default_sheet = '智慧'
			3.upto(book.last_row).each do |i|
				level = book.cell(i, 'A').to_i
				condition = {:player_level => book.cell(i, 'j').to_i}
				cost = {
					:wood => book.cell(i, 'C').to_i,
					:stone => book.cell(i, 'D').to_i,
					:gold => book.cell(i, 'E').to_i,
					:population => book.cell(i, 'F').to_i,
					:time => book.cell(i, 'G').to_i,
				}
				property = {
					:plunder => book.cell(i, 'B').to_f,
				}
				reward = {
					:experience => book.cell(i, 'H').to_i,
					:score => book.cell(i, 'i').to_i,
				}
				@@tech_const[definition['智慧']][level] ||= {}
				@@tech_const[definition['智慧']][level] = {
					:condition => condition,
					:cost => cost,
					:property => property,
					:reward => reward
				}
			end
		end
	end
	
	module InstanceMethods

		def all_info
			self.class.info[type]
		end
		
		def info
			all_info[level]
		end		

		def next_level
			all_info[level + 1]
		end

		def property
			info[:property]
		end

	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end