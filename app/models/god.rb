class God < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension

	attribute :type, 					Type::Integer
	attribute :level,					Type::Integer
	attribute :start_time, 		Type::Integer

	reference :player, Player

	protected

	def before_save
		self.start_time ||= ::Time.now.to_i		
	end
end
