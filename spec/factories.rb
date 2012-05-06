FactoryGirl.define do
	
	factory :player do
		sequence(:nickname) {|n| "gaofei_#{n}"}
	end

	factory :village do
		sequence(:name) {|n| "gaofei_#{n}'s village"}
	end

	factory :dinosaur do
		sequence(:type) {|n| n}
	end

	factory :session do
		session_key 	"session_key_test"
		expired_at	 	1.hour.since(Time.now.utc)
	end

	factory :building do
		type 			2
		level			1
		x 				100
		y					200
	end
end