source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.7'
# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 1.3.13'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

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
gem 'addressable', '~> 2.5'

gem 'pg'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13.0'
  gem 'selenium-webdriver'

  gem 'solr_wrapper', '>= 0.3'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
	gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

group :test do
  gem 'minitest-ci', '~> 3.0.3'
  gem 'minitest-reporters', '~> 1.1.8'

  # Code analysis tools
  gem 'rubocop', '~> 0.74.0', require: false
  gem 'rubocop-rails', '~> 2.3.0', require: false
  gem 'rubocop-checkstyle_formatter', '~> 0.2.0', require: false

  gem 'simplecov', require: false
  gem 'simplecov-rcov', require: false

  gem 'rails-controller-testing'

  gem 'rspec'
  gem 'rspec-mocks', '~> 3.8.1'
end

gem 'rsolr'

gem "sparql-client", "~> 3.0"

gem 'stomp'
