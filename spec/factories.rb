FactoryGirl.define do
	
	factory :player do
		sequence(:nickname) {|n| "gaofei_#{n}"}
	end

	factory :village do
		sequence(:name) {|n| "gaofei_#{n}'s village"}
	end

	factory :session do
		session_key 	"session_key_test"
		expired_time 	1.hour.since(Time.now)
	end

	factory :building do
		type 			2
		level			1
	end
end