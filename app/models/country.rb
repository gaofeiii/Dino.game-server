class Country < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Callbacks
	include CountryDataHelper
	include OhmExtension

	attribute :index, Type::Integer
	unique :index



	protected

	def after_delete
		# Clear up town and gold indices info.
		self.clear!
	end

end
