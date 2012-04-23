require 'spec_helper'

describe Dinosaur do

	describe "validations" do
		
	end

	describe "relationships" do
		
		before(:each) do
			@dinosaur = FactoryGirl.create(:dinosaur)
		end

		it "should respond_to player" do
			@dinosaur.should respond_to(:player)
		end

		it "should have correct player" do
			player = FactoryGirl.create(:player)
			@dinosaur.update :player_id => player.id
			@dinosaur.player.should == player
		end

		it "should respond_to village" do
			@dinosaur.should respond_to(:village)
		end

		it "should have correct village" do
			village = FactoryGirl.create(:village)
			@dinosaur.update :village_id => village.id
			@dinosaur.village.should == village
		end
	end
end
