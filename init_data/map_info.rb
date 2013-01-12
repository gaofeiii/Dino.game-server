puts '--- Initializing country and maps info ---'

if Country.count <= 0
	1.upto(1) do |i|
		country = Country.create :index => i
		country.init!
		country.create_gold_mines
		country.refresh_monsters
	end
end