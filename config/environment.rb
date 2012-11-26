p '=== Loading environment.rb ==='


# Set time zone to UTC
# ENV['TZ'] = "UTC"

# Load the rails application
require File.expand_path('../application', __FILE__)

const_dir = "#{Rails.root}/const"
require "#{const_dir}/const_helper.rb"
Dir[const_dir + '/*.rb', const_dir + '/**/*.rb'].each{|file| require file}

# Initialize the rails application
DinosaurGame::Application.initialize!

init_dir = "#{Rails.root}/init_data"
Dir[init_dir + '/*.rb', init_dir + '/**/*.rb'].each{|file| require file}

module StringExtensions
	CHARACTORS = ('A'..'Z').to_a + ('a'..'z').to_a + ('0'..'9').to_a

	module ClassMethods
		def sample(n = 1)
			str = ""
			1.upto(n).each{ str << CHARACTORS.sample }
			return str
		end
	end
	
	module InstanceMethods
		
	end
	
	def self.included(receiver)
		receiver.extend         ClassMethods
		receiver.send :include, InstanceMethods
	end
end

class String
	include StringExtensions
end