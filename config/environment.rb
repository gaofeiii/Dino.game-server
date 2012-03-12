# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
DinosaurGame::Application.initialize!

# 以下是为了实现Ohm Model中attribute设置default的功能
# 使用方法：
# attribute :money, :default => 0
# module Ohm
# 	class Model

# 		@@default_values = Hash.new { |hash, key| hash[key] = [] }

# 		def self.attribute(name, options = {})
# 			define_method(name) do
# 				read_local(name)
# 			end

# 			define_method(:"#{name}=") do |value|
# 				write_local(name, value)
# 			end

# 			unless options.nil?
# 				@@default_values[name.to_sym] = options[:default]
# 			end

# 			attributes << name unless attributes.include?(name)
# 		end

# 		def initialize(attrs = {})
#       @id = nil
#       @_memo = {}
#       @_attributes = Hash.new { |hash, key| hash[key] = read_remote(key) }
#       update_attributes(@@default_values.merge(attrs))
#     end
# 	end
# end