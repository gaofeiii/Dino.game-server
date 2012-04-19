FactoryGirl.define do
	
	factory :player do
		nickname		"gaofei"
	end

	factory :village do
		name 			"gaofei's village"
	end

	factory :session do
		session_key 	"session_key_test"
		expired_time 	1.hour.from_now.localtime
	end

end