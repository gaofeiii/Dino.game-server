class Building < GameClass
	attribute :type, Integer
	attribute :level, Integer
	attribute :x, Integer
	attribute :y, Integer

	index :type
	index :village_id

	reference :village, Village
end
