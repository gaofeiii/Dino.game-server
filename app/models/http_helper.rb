require 'net/http'

class HttpHelper
	
	class << self

		# If response is success, the return will be a symbolized hash
		def send_get(address)
			uri = URI.parse create_url(address)

			req = Net::HTTP::Get.new(uri.request_uri)

			currTime = ::Time.now.to_i
			req['Date'] = currTime.to_s
			req['Sig'] = Digest::MD5.hexdigest("#{req.fullpath}--#{currTime}--#{ServerInfo.account_server_private_key}")

			res = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }

			data = JSON.parse(res.body).deep_symbolize_keys
			p "--- account server data ---", data
			data
		end

		# Send http post request with json body
		def send_post(address, params = {})
			uri = URI.parse create_url(address)

			req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' => 'application/json'})
			req.body = params.to_json

			currTime = ::Time.now.to_i
			req['Date'] = currTime.to_s
			req['Sig'] = Digest::MD5.hexdigest("#{params.to_json}--#{currTime}--#{ServerInfo.account_server_private_key}")

			res = Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }

			data = JSON.parse(res.body).deep_symbolize_keys
			p "--- account server data ---", data
			data
		end

		def create_url(address)
			if address.downcase =~ /http:\/\//
				address
			else
				"http://#{address}"
			end
		end

	end
end