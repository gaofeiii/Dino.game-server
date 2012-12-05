# encoding: utf-8
module BuildingConst

	module ClassMethods
		@@building_const 	= Hash.new
		@@building_types 	= Array.new
		@@building_keys  	= Array.new
		@@building_hashes = Hash.new
		@@building_cost 	= Hash.new

		%w(const types keys hashes).each do |name|
			define_method(name) do
				if eval("@@building_#{name}").blank?
					reload!
				end
				eval("@@building_#{name}")
			end
		end

		alias info const

		def cost(type = nil)
			if @@building_cost.blank?
				info.each do |key, val|
					@@building_cost[key] = val[:cost]
				end
			end

			if type.nil?
				return @@building_cost
			end

			if types.include?(type)
				return const[type][:cost]
			else
				return {}
			end			
		end

		def reload!
			puts '--- Reading buildings const ---'
			@@building_const.clear
			@@building_types.clear
			@@building_keys.clear
			@@building_hashes.clear

			book = Excelx.new("#{Rails.root}/const/buildings.xlsx")

			book.default_sheet = "建造列表"

			2.upto(book.last_row) do |i|
				b_type = book.cell(i, 'B').to_i
				key = book.cell(i, 'M').to_sym
				cost = {
					:time => book.cell(i, 'G').to_i,
					:wood => book.cell(i, 'C').to_i,
					:stone => book.cell(i, 'D').to_i,
					:gold => book.cell(i, 'E').to_i,
					:population => book.cell(i, 'F').to_i
				}
				reward = {
					:experience => book.cell(i, 'H').to_i,
					:score => book.cell(i, 'I').to_i
				}
				@@building_const[b_type] = {:key => key}
				@@building_const[b_type].merge!(:cost => cost, :reward => reward)
				@@building_hashes[key] = b_type
			end
			@@building_types = @@building_const.keys
			@@building_keys = @@building_const.values.map { |v| v[:key] }

			@@building_const
		end
	end
	
	module InstanceMethods
		
		def info
			self.class.info[type]
		end

		def property
			self.class.info[type][:property]
		end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end