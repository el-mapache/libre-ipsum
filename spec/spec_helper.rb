ENV['RACK_ENV'] = "test"

require 'rack/test'
require 'rspec'
require 'rspec/mocks'

require File.expand_path(File.dirname(__FILE__) + '/../libre_ipsum')

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.mock_framework = :rspec
end

def app
  LibreIpsum
end
