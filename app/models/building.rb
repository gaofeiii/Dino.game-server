class Building < GameClass
	attribute :type, Integer
	attribute :level, Integer
	attribute :village_id, Integer

	index :type
	index :village_id

	def village
		Village[village_id]
	end
end
