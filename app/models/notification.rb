# encoding: utf-8
class Notification
	HOST = case ServerInfo.current[:env]
	when "production" 
		"gateway.push.apple.com"
	else
		"gateway.sandbox.push.apple.com"
	end

  PORT = 2195
  PASSPHRASE = '123'
  CERT_FILE_PATH = case ServerInfo.current[:env]
  when "production"
  	Rails.root.join("const").join("ds2_aps_production.pem")
  else
  	Rails.root.join("const").join("ds2_aps_development.pem")
  end

  class << self
  	def connect_apn
			cert_file = File.read(CERT_FILE_PATH)
			ctx = OpenSSL::SSL::SSLContext.new
			ctx.key = OpenSSL::PKey::RSA.new(cert_file, PASSPHRASE)
			ctx.cert = OpenSSL::X509::Certificate.new(cert_file)
			$s = TCPSocket.new(HOST, PORT)
			$ssl = OpenSSL::SSL::SSLSocket.new($s, ctx)
			$ssl.sync = true
			$ssl.connect
		end

		def send(device_token, message)
			if $ssl.nil? or $s.nil?
				self.connect_apn
			end

			message = push_message(device_token, message)

			begin
				$ssl.write(message)
				if IO.select([$ssl], nil, nil, 0.0001)

          read_buffer = $ssl.read(6)

          p "------ ", read_buffer

          p "!!!!! PUSHING ERROR !!!!! -- " + read_buffer[1].to_s
        end
        return true
      rescue Exception => e
      	p "----- error ---- "
        p e.to_s
        return false
			end

		end

		def push_message(device_token, message)
			hex = [device_token.delete(' ')].pack('H*')
			json_message = apple_hash_json(message)
			length = json_message.length
	    high = (length >> 8) & 255
	    low  = length & 255
			"\0\0\040#{hex}#{high.chr}#{low.chr}#{json_message}"
		end

		def apple_hash_json(msg = "Welcome to Dinosaur")
	    result = {}
	    result['aps'] = {}
	    result['aps']['badge'] = 0
	    result['aps']['sound'] = 'bingbong.aiff'
	    result['aps']['alert'] = msg
	    result.to_json
	  end

  end

	
end