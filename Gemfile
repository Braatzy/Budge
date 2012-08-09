source 'http://rubygems.org'
source 'http://gems.github.com'

gem 'acts_as_tree'
gem 'acts_as_list'
gem "aws-s3"
gem 'aws-sdk'
gem 'airbrake'
gem "braintree"
gem "delayed_job", '2.1.4'
gem 'exceptional'
gem "grape", :git => 'git://github.com/intridea/grape.git'
gem 'haml'
gem 'haml-rails'
gem 'hpricot'
gem 'i18n', '>= 0.4.2'
gem "jdpace-weatherman"
gem 'jquery-rails', '2.0.1'
gem "json", '>= 1.4.3'
gem "linguistics"
gem "manifesto" # For cache manifest
gem "mocha"
gem "oauth", '>= 0.4.0'
gem "paperclip", "~> 2.3"
gem 'rails', '>= 3.2.0'
gem 'rails_autolink'
gem 'RedCloth', '>= 4.2.7'
gem 'rdoc'
gem 'simplegeo'
#gem 'spatial_adapter'
gem "treetop"
gem "tumblr-rb"
gem "twilio-ruby"
gem "will_paginate"
gem 'kaminari'
gem "xml-simple"
gem "hominid"
gem "thin"
gem "devise"
gem "devise_oauth2_providable"

group :development do
  gem 'mysql2'
  gem 'execjs'
  gem 'libv8', '3.3.10.4'
  gem 'therubyracer'
  gem 'awesome_print'
  gem 'rack-test'
  gem 'taps'
end

group :alex_local, :staging, :adam_local do 
  # gem "pg"
  # gem 'taps'
  gem 'annotate'
  gem 'heroku'
end

group :adam_local do
  gem 'mysql2'
end
group :production do
  gem 'rake' #, '0.8.7'
  gem 'pg'
end

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test, :adam_local do
   gem 'fastercsv' # Needed for Ruby 1.8
   gem 'capybara'
   gem 'rspec'
   gem 'rspec-rails'
   gem 'cucumber'
   gem 'cucumber-rails'
   #gem 'factory_girl'
   #gem 'factory_girl_rails'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', " ~> 3.2.0"
  gem 'bootstrap-sass', '~> 2.0.1'  
  gem 'coffee-rails', " ~> 3.2.0"
  gem 'uglifier'
  gem "compass-rails"
  gem 'underscore-rails'
end
