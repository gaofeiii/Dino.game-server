require 'spec_helper'

describe Village do
  
  describe "validations" do
  	
  	before(:each) do
  		@attr = {:name => "Test"}
  		@player = Player.create :nickname => 'gaofei'
  	end

  	it "should have a player method" do
  		Village.new(@attr).should respond_to(:player)
  	end

  	it "should get the right player" do
  		vil = Village.create(@attr.merge(:player_id => @player.id))
  		vil.player.should == @player
  	end
  end
end
