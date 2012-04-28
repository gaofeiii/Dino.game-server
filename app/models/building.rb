class Building < GameClass
	attribute :type, Integer
	attribute :level, Integer
	attribute :status, Integer
	attribute :x, Integer
	attribute :y, Integer

	index :type
	index :village_id

	reference :village, Village

	def initialize(attrs = {})
		super
		self.level = 1
		self.status = 0
	end

	def to_hash
		super.merge(:time => 0)
	end
end
