if Country.count <= 0
	puts '--- Initializing country and maps info ---'
	1.upto(1) do |i|
		country = Country.create :index => i
		# country.init_new!
		# country.create_gold_mines
	end
end