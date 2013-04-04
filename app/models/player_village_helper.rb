module PlayerVillageHelper
	module ClassMethods
		
	end
	
	module InstanceMethods
		def village
			Village[village_id]
		end

		def buildings
			vil = Village.new(:id => village_id)
			vil.buildings
		end

		def refresh_village_status
			self.buildings.find(:type => 0).union(:type => 1, :village_id => village_id).each do |build|
				build.update_status!
			end

			self.dinosaurs.find(:status => 0).each do |dino|
				dino.update_status!
			end
		end

		def village_level
	  	l = (level / 10.0).ceil
	  	l = 3 if l > 3
	  	l
	  end

	  def visit_info
			vil = self.village
			hash = self.to_hash
			hash[:village] = vil.to_hash
			hash[:village][:buildings] = vil.buildings.map { |bd| bd.to_hash(:steal_info) }
			hash
		end

		# Return [x, y]
		def find_rand_coords(country = Country.first)
			start_x, start_y = 500, 500

			empty_town_nodes = country.town_nodes_info.keys - country.used_town_nodes
			factor = Country::COORD_TRANS_FACTOR


			# 55.step(499, 2) do |coord_fact|
			# 	min_x = start_x - coord_fact
			# 	max_x = start_x + coord_fact
			# 	min_y = start_y - coord_fact
			# 	max_y = start_y + coord_fact

			# 	all_points = ([min_x, max_x].product((min_y..max_y).to_a) + [min_y, max_y].product((min_x..max_x).to_a)).uniq

			# 	avai_nodes = all_points.map!{|point| point[0] + point[1] * factor} & empty_town_nodes

			# 	node = avai_nodes.sample
			# 	avai_nodes.delete(node)

			# 	until !node.in?(country.used_town_nodes)
			# 		if node
			# 			return [node % factor, node / factor]
			# 		end

			# 		if avai_nodes.empty?
			# 			break
			# 		else
			# 			node = avai_nodes.sample
			# 			avai_nodes.delete(node)
			# 		end
			# 	end

				
			# end

			rand_node = empty_town_nodes.sample
			[rand_node % factor, rand_node / factor]
			# [x, y]
		end
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end