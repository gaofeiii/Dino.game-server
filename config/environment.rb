p '=== Loading environment.rb ==='


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