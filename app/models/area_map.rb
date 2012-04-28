class AreaMap < GameClass
	attribute :x, 			Integer
	attribute :y, 			Integer
	attribute :blocked, Boolean

	index :x
	index :y
	index :blocked

	def initialize(args = {})
		super
		self.blocked = false if blocked.nil?
	end
end
