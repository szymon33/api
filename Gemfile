source 'https://rubygems.org'
ruby '2.1.8'

gem 'rails', '3.2.22'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem "pg", "~> 0.14.1"

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
  gem 'execjs'
  gem 'therubyracer'
end

gem 'jquery-rails'

group :test do
  gem 'factory_girl_rails', '~> 4.2.1'
  gem 'rspec-rails', '~> 2.0'
  gem 'shoulda-matchers', require: false
  gem 'foobar'
  gem 'database_cleaner'
  gem 'codeclimate-test-reporter', require: nil
  gem 'simplecov', require: false
end

group :development do
  gem 'thin' # if not werbrick
  gem 'pry'
  gem 'quiet_assets'
end
