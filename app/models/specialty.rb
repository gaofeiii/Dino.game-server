class Specialty < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Callbacks
	include Ohm::Timestamps

	include OhmExtension

	attribute :category, 	Type::Integer
	attribute :type, 			Type::Integer
	attribute :count,	 		Type::Integer

	index :category
	index :type

	reference :player, 	:Player


	[:name, :feed_point].each do |att|
		define_method(att) do
			SPECIALTIES[type][att]
		end
	end

	def to_hash
		hash = {
			:id => id.to_i,
			:category => category,
			:type => type,
			:count => count
		}
	end

	protected

	def before_create
		self.category = 2
	end
end