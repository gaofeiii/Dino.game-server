puts '=== Loading environment.rb ==='


# Set time zone to UTC
# ENV['TZ'] = "UTC"

# Load the rails application
require File.expand_path('../application', __FILE__)

const_dir = "#{Rails.root}/const"
Dir[const_dir + '/*.rb', const_dir + '/**/*.rb'].each{|file| require file}

require "#{Rails.root}/config/server_info.rb"

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
	def to_percentage(keep = 1)
		if keep
			return format("%.#{keep}f%", self * 100)
		else
			return format("%f%", self * 100)
		end
	end
end

::Point = Struct.new(:x, :y, :type) do
	def index
		return (self.x.to_i + (self.y.to_i * Country::COORD_TRANS_FACTOR))
	end

	def +(other)
		self.class.new(self.x + other.x, self.y + other.y)
	end

	def ==(other)
		if self.x == other.x && self.y == other.y
			return true
		else
			return false
		end
	end

	# Return an array of points
	def product(other)
		[self.x, self.y].product([other.x, other.y]).map!{|coords| Point.new(*coords)}
	end

	# Return the points of the straight line between two points
	def self.line_points(pt1, pt2)
		[]
	end
end