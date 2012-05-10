class Country < GameClass
	attribute :name, Symbol
	attribute :serial_id, Integer
	unique :serial_id
end
