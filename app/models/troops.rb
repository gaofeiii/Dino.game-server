class Troops < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension

	collection :dinosaurs, Dinosaur

	reference :player, Player

	def dissolve!
		delete
	end

end
