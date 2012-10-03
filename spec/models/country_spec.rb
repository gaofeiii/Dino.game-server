require 'spec_helper'

describe Country do

	before(:each) do
		@attr = {:index => 11}
	end

	describe "Validations" do
		
		it "should create a country" do
			lambda do
				Country.create @attr
			end.should change(Country, :count).by(1)
		end

	end
end
