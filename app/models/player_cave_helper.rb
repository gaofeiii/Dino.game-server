module PlayerCaveHelper
	CAVE_RANGE = 1..96

	module ClassMethods
		
	end
	
	module InstanceMethods
		def full_cave_stars_info
			result = Array.new(CAVE_RANGE.max, -1)

			self.caves.ids.each do |cave_id|
				cave = PlayerCave.new(:id => cave_id).gets(:index, :stars)
				result[cave.index - 1] = cave.stars
			end
			result
		end

		def find_cave(idx)
			self.caves.find(:index => idx).first
		end

		def create_cave(idx)
			return if (idx <= 0 || caves.find(:index => idx).any?)
			PlayerCave.create :index => idx, :player_id => id
		end

		def latest_cave_id
			caves.ids.map!{|c_id| c_id.to_i}.max
		end

		# should be ranged in CAVE_RANGE
		# if not reached max, the stars should be ZERO
		def latest_cave
			PlayerCave[latest_cave_id]
		end

		def update_caves_info
			latest_id = latest_cave_id

			if latest_id
				idx, latest_cave_stars = db.hmget(PlayerCave.key[latest_id], :index, :stars).map(&:to_i)

				if latest_cave_stars > 0
					create_cave(idx + 1) if idx < CAVE_RANGE.max
				end
			else
				create_cave(CAVE_RANGE.min)
			end
		end

		def max_cave_count
			is_vip? ? 5 : 3
		end

	end
	
	def self.included(model)
		model.collection :caves,						PlayerCave

		model.extend         ClassMethods
		model.send :include, InstanceMethods
	end
end