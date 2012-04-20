require 'spec_helper'

describe Session do

	describe "Validations" do
		
		before(:each) do
			@attr = {:session_key => "Test_SeSSion_KeY", :expired_time => 1.day.since(Time.now)}
		end

		it "should be create a session" do
			lambda do
				Session.create @attr
			end.should change(Session, :count).by(1)
		end
	end
	
end
