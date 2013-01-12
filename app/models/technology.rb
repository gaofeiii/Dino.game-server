# 1	住宅
# 2	伐木
# 3	采石
# 4	狩猎
# 5	采集
# 6	储藏
# 7	孵化
# 8	驯养
# 9	商业
# 10	科研
# 11	祭祀
# 12	炼金
# 13	勇气
# 14	刚毅
# 15	忠诚
# 16	仁义
# 17	寻宝
# 18	残暴
# 19	掠夺
# 20	智慧
class Technology < Ohm::Model
	STATUS = {:idle => 0, :researching => 1}

	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include OhmExtension

	include TechnologiesConst

	attribute :level, 			Type::Integer
	attribute :type,				Type::Integer
	attribute :status, 			Type::Integer
	attribute :start_time, 	Type::Integer
	attribute :finish_time, Type::Integer
	attribute :building_id, Type::Integer

	index :type
	index :status

	reference :player, :Player

	def research!(bid)
		self.status = STATUS[:researching]
		self.start_time = ::Time.now.to_i
		self.finish_time = ::Time.now.to_i + next_level[:cost][:time]
		self.building_id = bid
		self.save
	end

	def to_hash
		hash = {
			:level => level,
			:type => type,
			:status => status
		}
		if status == STATUS[:researching]
			hash[:total_time] = next_level[:cost][:time]
			hash[:time_pass] = ::Time.now.to_i - start_time
			hash[:building_id] = building_id
		end
		hash
	end

	def research_finished?
		if status == STATUS[:researching]
			return false if ::Time.now.to_i < finish_time
		end
		return true
	end

	def village
		Village[db.hget(Player.key[player_id], :village_id)]
	end

	def update_status!
		if status == STATUS[:researching]
			if ::Time.now.to_i >= finish_time
				self.status = STATUS[:idle]
				self.level = level + 1
				self.start_time = 0
				self.finish_time = 0
				self.save
			end
		end
		self
	end

	def speed_up_gem_cost
		l_time = finish_time - start_time
		l_time = 0 if l_time < 0
		(l_time / 300.0).ceil
	end

	def speed_up_cost
		{:gems => speed_up_gem_cost}
	end

	def speed_up!
		if status == STATUS[:researching]
			self.finish_time = ::Time.now.to_i
			update_status!
		end
	end

	protected

	def before_create
		self.status = 0
		self.start_time = 0
		self.finish_time = 0
	end

	def after_save
		case type
		when Technology.hashes[:residential]
			self.player.update_building_workers!
		when Technology.hashes[:storing]
			self.village.update_warehouse! if level > 0
		end
	end
end
