require 'spec_helper'

describe Village do
  
  describe "validations" do
  	
  	before(:each) do
  		@attr = {:name => "Test"}
  	end

  end

  describe "Relationships" do
    
    before(:each) do
      @player = FactoryGirl.create(:player)
      @village = FactoryGirl.create(:village)
    end

    it "should respond_to player" do
      @village.should respond_to(:player)
    end

    it "should get the right player" do
      @village.update :player_id => @player.id
      @village.player.should == @player
    end

    it "should respond_to buildings" do
      @village.should respond_to(:buildings)
    end

    it "should include a specified building" do
      building = FactoryGirl.create(:building, :village_id => @village.id)
      @village.reload.buildings.should include(building)
    end

    it "should set player success" do
      @village.player = @player
      @village.player.should == @player
    end

    it "should respond_to dinosaurs" do
      @village.should respond_to(:dinosaurs)
    end

    it "should have the correct dinosaurs" do
      d1 = FactoryGirl.create(:dinosaur, :village_id => @village.id)
      @village.dinosaurs.should include(d1)
    end

  end
















end
