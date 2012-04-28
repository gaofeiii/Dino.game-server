p 'Loading enviornment.rb...'

# Set time zone to UTC
ENV['TZ'] = "UTC"

# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
DinosaurGame::Application.initialize!

const_dir = "#{Rails.root}/const"
Dir[const_dir + '/*.rb', const_dir + '/**/*.rb'].each{|file| require file}