ENV['RACK_ENV'] ||= 'text'
require 'assets_server'
require 'rack/test'
require 'pry'

Dir[Bundler.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.order = "random"

  config.include Rack::Test::Methods

end
