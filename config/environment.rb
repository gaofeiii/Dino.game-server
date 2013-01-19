puts '=== Loading environment.rb ==='


# Set time zone to UTC
# ENV['TZ'] = "UTC"

# Load the rails application
require File.expand_path('../application', __FILE__)

const_dir = "#{Rails.root}/const"
Dir[const_dir + '/*.rb', const_dir + '/**/*.rb'].each{|file| require file}

# Initialize the rails application
DinosaurGame::Application.initialize!

init_dir = "#{Rails.root}/init_data"
Dir[init_dir + '/*.rb', init_dir + '/**/*.rb'].each{|file| require file}

class String
	include GameStringExtension
end

class Float
	# 0.125.to_percentage 		# => "12.50%"
	# 0.125.to_percentage(0) 	# => "12%"
	def to_percentage(keep = 2)
		if keep
			return format("%.#{keep}f%", self * 100)
		else
			return format("%f%", self * 100)
		end
	end
end