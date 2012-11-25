class Error

	class << self
		def format_message(msg)
			msg.gsub(/\.|\,|\'/, '').split(' ').join('_').upcase
		end
	end
end