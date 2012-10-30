p '--- Initializing country and maps info ---'

if Country.count <= 0
	1.upto(1) do |i|
		country = Country.create :index => i
		country.init!
	end
end