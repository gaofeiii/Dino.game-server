class Building < GameClass
	attribute :type, Integer
	attribute :level, Integer

	index :type
	index :village_id

	reference :village, Village
end
