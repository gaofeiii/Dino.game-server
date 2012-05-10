class Country < GameClass
	attribute :name, Symbol
	attribute :serial_id, Integer
	unique :serial_id

	index :name
	index :serial_id
end
