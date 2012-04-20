require 'spec_helper'

describe PlayersController do

	before(:each) do
		@player = FactoryGirl.create(:player)
	end

	it "should GET player's info success" do
		get :show, :id => @player.id
		response.should be_success
		response.body.should include(@player.nickname)
	end

	it "should GET failed when player not exist" do
		get :show, :id => 4394
		response.should_not be_success
		response.body.should include("Player not found")
	end

	it "should GET 'index' find player by session_key" do
		sess = FactoryGirl.create(:session, :player_id => @player.id)
		get :index, :session_key => sess.session_key
		response.should be_success
		response.body.should include(@player.nickname)
	end

	it "should GET 'index' failed when session_key is not found" do
		get :index, :session_key => 'bla bla bla bla'
		response.should_not be_success
		response.body.should include("Player not found")
	end
end
