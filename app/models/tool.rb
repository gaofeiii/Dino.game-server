class	Tool

	class << self

		# Tool.rate(0.5) 	# => true or false
		# Tool.rate(0)		# => false
		# Tool.rate(1)	 	# => true
		# Tool.rate(234)	# => true
		def rate(value = 0.0)
			Random.rand <= value.to_f
		end

	end
end