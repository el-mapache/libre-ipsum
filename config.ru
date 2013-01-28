require 'rubygems'
require 'bundler'
Bundler.require(:default)

require './libre_ipsum.rb'
require './api_throttle.rb'

sprockets = Sprockets::Environment.new do |env|
	env.logger = Logger.new(STDOUT)
end

sprockets.append_path 'assets/javascripts'
sprockets.append_path 'assets/stylesheets'

use ApiThrottle, requests_per_hour: 100
run LibreIpsum
