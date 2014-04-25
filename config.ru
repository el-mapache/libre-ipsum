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

redis_port_no = unless ENV['APP_ENV'].nil?
                  22312
                else
                  6379
                end

use ApiThrottle, requests_per_hour: 100, redis_port: redis_port_no
run LibreIpsum
