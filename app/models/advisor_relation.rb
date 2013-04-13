class AdvisorRelation < Ohm::Model
	include Ohm::DataTypes
	include Ohm::Timestamps
	include Ohm::Callbacks
	include Ohm::Locking
	include OhmExtension

	attribute :type, 				Type::Integer
	attribute :advisor_id,	Type::Integer
	attribute :price,				Type::Integer

	index :type
	index :price

	reference :employer,		Player

	def advisor
		Player[advisor_id]
	end

	def to_hash
		@advisor = advisor

		{
			:type => type,
			:player_id => advisor_id,
			:nickname => @advisor.nickname,
			:avatar_id => @advisor.avatar_id,
			:price => price,
			:left_time => created_at + 1.day - Time.now.to_i
		}
	end

	protected

	def after_delete
		@advisor = advisor
		@advisor.set :advisor_relation_id, nil if @advisor
	end
end