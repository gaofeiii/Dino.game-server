require 'spec_helper'

describe Player do

	describe "validations" do
		
		before(:each) do
			@attr = {:nickname => "gaofei"}
			@village = FactoryGirl.create(:village)
		end

		it "level and experience should be default value when not assigned" do
			player = Player.new @attr
			player.save
			# player.level.should == 1
			player.experience.should == 0
		end

		# it "should be invalid when level is not a number" do
		# 	player = Player.new @attr
		# 	player.level = 'xxx'
		# 	player.should_not be_valid
		# end

		it "should respond_to created_at updated_at" do
			player = Player.new @attr
			player.should respond_to(:created_at)
			player.should respond_to(:updated_at)
		end
	end

	describe "Instance method validations" do
		
		before(:each) do
			@player = FactoryGirl.create(:player)
			@village = FactoryGirl.create(:village)
		end

		it "should have a village method" do
			@player.should respond_to(:village)
		end

		it "should get the correct village" do
			@player.village_id = @village.id
			@player.village.should == @village
		end

		it "should respond_to session" do
			@player.should respond_to(:session)
		end

		it "should have the correct session" do
			sess = FactoryGirl.create(:session, :player_id => @player.id)
			@player.session_id = sess.id
			@player.session.should == sess
		end

		it "should have a logined? method" do
			@player.should respond_to(:logined?)
		end

		it "should return true when player's session is valid" do
			sess = FactoryGirl.create(:session, :player_id => @player.id)
			@player.update :session_id => sess.id
			@player.should be_logined
		end

		it "should return false when player's session is expired" do
			sess = FactoryGirl.create(:session, :expired_at => 1.hour.ago.localtime, :player_id => @player.id)
			@player.update :session_id => sess.id
			@player.session.should_not be_nil
			@player.should_not be_logined 
		end

		it "should respond_to dinosaurs" do
			@player.should respond_to(:dinosaurs)
		end

		it "should have the correct dinosaurs" do
			d1 = FactoryGirl.create(:dinosaur, :player_id => @player.id)
			@player.dinosaurs.should include(d1)
		end
	end
































end
