require 'spec_helper'

describe Player do

	describe "validations" do
		
		before(:each) do
			@attr = {:nickname => "gaofei"}
			@village = Village.create :name => "gaofei's village"
		end

		it "should have a vlliage method" do
			Player.new(@attr).should respond_to(:village)
		end

		it "should get the current village" do
			player = Player.create @attr.merge(:village_id => @village.id)
			player.village.should == @village
		end
	end
end
