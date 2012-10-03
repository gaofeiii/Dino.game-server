require 'spec_helper'

describe MailsController do

	before(:each) do
		@player1 = FactoryGirl.create(:player)
		@player2 = FactoryGirl.create(:player)
	end

	it "should send personal mail successfully" do
		@player2.mails(Mail::TYPE[:private]).map { |mail| mail.delete  }
		post 'send_mail', :sender => @player1.nickname, :receiver => @player2.nickname, :tilte => "hello", 
		:content => "world", :mail_type => Mail::TYPE[:private]
		response.should be_success
		response.body.should include("Success")
		@player2.mails(Mail::TYPE[:private]).size.should == 1
	end

	it 'should send league mail successfully' do
		@league = FactoryGirl.create(:league, :president_id => @player1.id)
		FactoryGirl.create(:league_member_ship, :player_id => @player1.id, :level => LEAGUE_MEMBER_LEVELS[:president])
		FactoryGirl.create(:league_member_ship, :player_id => @player2.id, :level => LEAGUE_MEMBER_LEVELS[:member])
		@player1.update :league_id => @league.id
		@player2.update :league_id => @league.id
		@player2.mails(Mail::TYPE[:league]).map { |mail| mail.delete }
		post 'send_mail', :sender => @player1.nickname, :league_id => @league.id, :mail_type => Mail::TYPE[:league],
		:title => "Hello", :content => "World"
		response.should be_success
		response.body.should include("Success")
		@player2.mails(Mail::TYPE[:league]).size.should == 1
	end

end
