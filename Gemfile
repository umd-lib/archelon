source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.6.2'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use Puma as the app server
gem 'puma', '>= 4.3.11'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Use jquery as the JavaScript library
gem 'jquery-rails'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 1.1.0', group: :doc

# Blacklight Gems
gem 'blacklight', '~> 6.0'
gem 'therubyracer'

# CAS Authentication
gem 'omniauth-cas', '~> 1.1.1'

# LDAP
gem 'net-ldap', '~> 0.16.1'

# dotenv - For storing production configuration parameters
gem 'dotenv-rails'

# clipboard - Uses clipboard.js to provide "Copy to Clipboard" functionality
gem 'clipboard-rails', '~>1.7.1'

# Pagination
gem 'will_paginate', '~> 3.1.0'
gem 'will_paginate-bootstrap', '~> 1.0.0'

# Table sorting
gem 'ransack'

# Used by Rake tasks to generate sample data
gem 'faker', '~> 1.8'

gem 'http', '~> 2.2.2'

# RFC-complient URI and URI template handling
gem 'addressable', '~> 2.8'

gem 'pg'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
	gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

gem "boathook", git: 'https://github.com/umd-lib/boathook', branch: 'main'

group :test do
  # Adds support for Capybara system testing and selenium driver
	gem 'capybara', '>= 2.15'
	gem 'selenium-webdriver'
 	# Easy installation and use of web drivers to run system tests with browsers
	gem 'webdrivers'

  gem 'minitest-reporters'

  # Code analysis tools
  gem 'rubocop', '~> 0.74.0', require: false
  gem 'rubocop-rails', '~> 2.3.0', require: false
  gem 'rubocop-checkstyle_formatter', '~> 0.2.0', require: false

  gem 'simplecov', require: false
  gem 'simplecov-rcov', require: false

  gem 'rails-controller-testing'

  gem 'rspec'
  gem 'rspec-mocks', '~> 3.8.1'

  # Note: The "action-cable-testing" gem can be removed when migrating to
  # Rails 6, as the gem is already included as part of Rails 6.
  gem 'action-cable-testing'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'rsolr'

gem "sparql-client", "~> 3.0"

gem 'stomp'

gem 'mechanize'

gem 'rdf-turtle'
gem 'json-ld'
gem 'cancancan'

gem 'webpacker'
gem 'react-rails'
gem 'delayed_job_active_record', '~> 4.1'
gem 'faraday', '~> 1.0'
gem 'delayed_cron_job', '~> 0.8'
