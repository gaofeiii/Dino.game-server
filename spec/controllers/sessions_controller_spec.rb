require 'spec_helper'

describe SessionsController do

	before(:each) do
		@user = { :id => 1, :username => "gaofei", :password => "foobar" }
	end

	describe "Post create" do

		before(:each) do
			@player = FactoryGirl.create(:player, :account_id => @user[:id])
		end

		describe "success" do
			
			it "should return success" do
				post :create, :session_key => 'abcdefg', :account_id => @user[:id]
				response.should be_success
				@player.load!.should be_logined
			end

			it "should create a player" do
				lambda do
					post :create, :session_key => "xixihaha", :account_id => 100
					response.should be_success
				end.should change(Player, :count).by(1)
			end
		end

	end
end
