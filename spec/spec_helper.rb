ENV['RACK_ENV'] = "test"

require 'rack/test'
require File.expand_path(File.dirname(__FILE__) + '/../libre_ipsum')

RSpec.configure do |config|
  config.include Rack::Test::Methods
end

def app
  LibreIpsum
end
