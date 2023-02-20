source 'https://rubygems.org'

gem 'sinatra', '~> 3.0.5'
gem 'sequel', '~> 5.65.0'
gem 'chartkick', '~> 5.0.1'
gem 'buildkit', '~> 1.5.0'
gem 'httparty', '~> 0.21.0'
gem 'rake', '~> 13.0.6'

group :development, :test do
  gem 'sqlite3', '~> 1.6.0'
  gem 'rspec'
  gem 'rack-test'
  gem 'capybara'
  gem 'simplecov', require: false
  gem 'codecov', '~> 0.2.8', require: false
end

group :production do
  gem 'pg', '~> 1.4.5'
end
