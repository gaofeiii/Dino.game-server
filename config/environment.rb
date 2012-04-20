p 'Loading enviornment.rb...'

# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
DinosaurGame::Application.initialize!

const_dir = "#{Rails.root}/config/const"
Dir[const_dir + '/*.rb', const_dir + '/**/*.rb'].each{|file| require file}