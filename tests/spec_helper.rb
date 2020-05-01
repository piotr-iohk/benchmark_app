require 'simplecov'
require 'capybara/rspec'

SimpleCov.start do
  add_filter %r{^/tests/}
end

if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require_relative '../app'  # <-- your sinatra app
require_relative '../helpers/readers'
require_relative '../helpers/data_transfer'
