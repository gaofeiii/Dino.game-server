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
				post :create, @user.except(:id)
				response.should be_success
			end
		end

		describe "failure" do
			
			it "should return success" do
				delete :destroy, :player_id => @player.id
				response.should be_success
			end
		end
	end
end
