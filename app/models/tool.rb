class	Tool
	MAG_FACTOR = 100000000
	REGULAR_RANGE = 0..1

	class << self

		# Tool.rate(0.5) 	# => true or false
		# Tool.rate(0)		# => false
		# Tool.rate(1)	 	# => true
		# Tool.rate(234)	# => true
		def rate(value = 0.0)
			Random.rand <= value.to_f
		end

		# 适用于物品区间概率掉落
		# Example:
		# 	odds_arr 		=> [0.6, 0.3, 0.1]
		# 	reward_arr 	=> [1, 2, 3]
		# 
		# 	Tool.range_drop(odds_arr, reward_arr) # => 1
		# 	Tool.range_drop(odds_arr, reward_arr) # => 2
		# 	...
		#
		def range_drop(odds_arr, reward_arr)
			return false if odds_arr.size != reward_arr.size

			# 扩大原始概率数组
			mag_odds_arr = odds_arr.map { |element| (element * MAG_FACTOR).to_i }
			random_max = mag_odds_arr.sum

			return false unless (0..MAG_FACTOR).include?(random_max)

			# 概率数组->区间数组
			range_arr = array_to_range_array(mag_odds_arr)
			# 得到一个随机数
			rand_one = Random.rand(MAG_FACTOR)

			# 循环区间数组，若随机数在某个区间内则返回对应的reward，否则返回空
			range_arr.each_with_index do |range, idx|
				return reward_arr[idx] if rand_one.in?(range)
			end

			nil
		end

		def array_to_range_array(array)
			start_pointer = 0

			range_arr = []

			array.each do |element|
				range_arr << Range.new(start_pointer + 1, start_pointer + element)
				start_pointer += element
			end

			return range_arr
		end

	end
end