class Redis
	def srandmembers(key, count = 1)
    synchronize do |client|
      client.call([:srandmember, key, count])
    end
  end
end