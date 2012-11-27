class Error
	TYPES = {
		:normal => 1
	}

	class << self
		def format_message(msg)
			msg.gsub(/\.|\,|\'|\-|\_/, ' ').split(' ').join('_').upcase
		end

		def types
			TYPES
		end

		def failed_message
			"FAILED"
		end

		def success_message
			"SUCCESS"
		end
	end
end