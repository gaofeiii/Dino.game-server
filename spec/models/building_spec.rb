require 'spec_helper'

describe Building do

	describe "Relationships" do
		
		before(:each) do
			@building = FactoryGirl.create(:building)
		end

		it "should respond to village" do
			@building.should respond_to(:village)
		end

		it "should get the correct village" do
			village = FactoryGirl.create(:village)
			building_b = FactoryGirl.create(:building, :village_id => village.id)
			building_b.village.should == village
		end
	end
end
