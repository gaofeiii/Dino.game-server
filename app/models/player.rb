class Player < GameClass

	attribute :account_id, Integer
	attribute :nickname, String
	attribute :level, Integer
	attribute :experience, Float
	attribute :village_id, Integer
	
	index :nickname
	index :village_id
	index :level

	def initialize(args = {})
		super
		self.level = 1 if level.nil?
		self.experience = 0 unless experience
	end


	def village
		Village[village_id]
	end

	def as_json
		
	end

end
