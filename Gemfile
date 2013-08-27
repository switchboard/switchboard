source 'https://rubygems.org'

gem 'rails', '3.2.13'

gem 'mysql2'
gem 'thin'
gem 'haml-rails'
gem 'twilio-ruby'
gem 'coffee-filter'
gem 'rails_config'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'compass-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'libv8', '3.11.8.3'  # see https://github.com/cowboyd/therubyracer/issues/215
  gem 'therubyracer', :platform => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
gem 'spine-rails'
gem 'dynamic_form'
gem 'simple_form'
gem 'kaminari'
gem 'paperclip'
gem 'airbrake'

# Authorization
gem 'omniauth'
gem 'omniauth-google-oauth2'
gem 'omniauth-facebook'
gem 'bcrypt-ruby'


group :development do
  gem 'sextant'
  gem "capistrano"
  gem "capistrano-ext"
end

group :test do
  gem 'shoulda'
  gem 'factory_girl_rails'
  gem 'mocha'
end

group :autotest do
  gem 'autotest-standalone'
  gem 'autotest-rails-pure'
  gem 'autotest-growl'
  gem 'autotest-fsevent'
end