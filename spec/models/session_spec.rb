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

	describe "Relationships Validations" do
		
		before(:each) do
			@sess = FactoryGirl.create(:session)
			@player = FactoryGirl.create(:player, :session_id => @sess.id)
			@sess.update :player_id => @player.id
		end

		it "should respond to 'player' method" do
			@sess.should respond_to(:player)
		end

		it "should get the corrent player" do
			@sess.player.should == @player
		end
	end
	
end
