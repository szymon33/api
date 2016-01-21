source 'https://rubygems.org'
ruby '2.1.8'

gem 'rails', '3.2.22'
gem "pg", "~> 0.14.1"

group :test do
  gem 'factory_girl_rails', '~> 4.2.1'
  gem 'rspec-rails', '~> 2.0'
  gem 'shoulda-matchers', require: false
  gem 'foobar'
  gem 'codeclimate-test-reporter', require: nil
  gem 'simplecov', require: false
  gem 'database_cleaner'
end

group :development do
  gem 'thin' # if not werbrick
  gem 'pry'
end
