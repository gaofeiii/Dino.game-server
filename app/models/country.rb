class Country < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Callbacks
	include Ohm::Timestamps
	include OhmExtension

	attribute :name
	attribute :serial_id
	unique :serial_id

	index :name
end
