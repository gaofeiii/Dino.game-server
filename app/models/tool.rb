class	Tool

	class << self

		# Tool.rate(0.5) 	# => true or false
		# Tool.rate(0)		# => false
		# Tool.rate(1)	 	# => true
		# Tool.rate(234)	# => true
		def rate(value)
			Random.rand <= value
		end

	end
end