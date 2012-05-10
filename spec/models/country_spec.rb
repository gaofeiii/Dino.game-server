require 'spec_helper'

describe Country do

	before(:each) do
		@attr = {:name => :atlantic, :serial_id => 1}
	end

	describe "Validations" do
		
		it "should create a country" do
			lambda do
				Country.create @attr
			end.should change(Country, :count).by(1)
		end

		# it "should have a unique serial_id" do
		# 	lambda do
		# 		cty = FactoryGirl.create(:country)
		# 		Country.create @attr.merge(:serial_id => cty.serial_id)	
		# 	end.should_not change(Country, :count)
		# end

	end
end
