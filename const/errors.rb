def format_error_message(msg)
	msg.gsub(/\.|\,|\'/, '').split(' ').join('_').upcase
end