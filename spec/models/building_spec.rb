require 'spec_helper'

describe Building do

	describe "Relationships" do
		
		before(:each) do
			@building = FactoryGirl.create(:building)
		end

		it "should respond to village" do
			@building.should respond_to(:village)
		end
	end
end
