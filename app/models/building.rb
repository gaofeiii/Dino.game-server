class Building < GameClass
	attribute :type, Integer
	attribute :level, Integer
	attribute :village_id, Integer

	index :type
	index :village_id

	reference :village, Village
end
