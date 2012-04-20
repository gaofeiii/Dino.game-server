require 'spec_helper'

describe BuildingsController do

	before(:each) do
		@player = FactoryGirl.create(:player)
		@village = FactoryGirl.create(:village, :player_id => @player.id)
		@player.update :village_id => @village.id
	end

	it "should POST 'create' success" do
		lambda do
			post :create, :player_id => @player.id, :village_id => @village.id, :building_type => 2
			response.should be_success
		end.should change(@village.buildings, :count).by(1)
	end
end
