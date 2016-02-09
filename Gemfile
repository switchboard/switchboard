source 'https://rubygems.org'

gem 'rails', '3.2.22'

gem 'mysql2', '0.3.20'
gem 'haml-rails'
gem 'twilio-ruby'
gem 'coffee-filter'
gem 'rails_config'
gem 'sass-rails'
gem 'font-awesome-rails'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails'
  gem 'compass-rails'
  gem 'compass-blueprint'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
gem 'spine-rails'
gem 'dynamic_form'
gem 'simple_form'
gem 'kaminari'
gem 'paperclip'
gem 'airbrake'
# Included by capistrano-resque but needs upgrade
gem 'resque-scheduler', git: 'https://github.com/resque/resque-scheduler.git'
gem 'resque'
gem 'aasm'
gem 'strong_parameters'

# Authorization
gem 'omniauth'
gem 'omniauth-google-oauth2'
gem 'omniauth-facebook'
gem 'bcrypt-ruby'

# This is for Rails 3.2 and Ruby 2.2
gem 'test-unit', '~> 3.0'

group :development do
  gem 'sextant'
  gem 'capistrano-rails', github: 'capistrano/capistrano-rails'
  gem 'capistrano-bundler'
end

group :test do
  gem 'minitest', require: 'minitest/autorun'
  gem 'shoulda'
  gem 'factory_girl_rails'
  gem 'mocha', require: 'mocha/setup'
  gem 'resque_unit'
  gem 'timecop'
  gem 'vcr'
  gem 'webmock'
end

group :autotest do
  gem 'autotest-standalone'
  gem 'autotest-rails-pure'
  gem 'autotest-growl'
  gem 'autotest-fsevent'
end