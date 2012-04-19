require 'spec_helper'

describe VillagesController do

	before(:each) do
		@village = FactoryGirl.create(:village)
		@player = FactoryGirl.create(:player, :village_id => @village.id)
		@village.update :player_id => @player.id
	end

	it "should GET the player's village" do
		get :index, :player_id => @player.id
		response.should be_success
		response.body.should include(@village.name)
	end

	it "should GET failed" do
		get :index, :player_id => 98989
		response.should_not be_success
		response.body.should include("Player not found")
	end
end
