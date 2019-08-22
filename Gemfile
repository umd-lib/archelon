source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0'
# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 1.3.13'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0', '>= 5.0.6'
# see https://nvd.nist.gov/vuln/detail/CVE-2019-8331
gem "bootstrap-sass", ">= 3.4.1"
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Blacklight Gems
gem 'blacklight', '~> 6.0'
gem 'therubyracer'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw]

# CAS Authentication
gem 'omniauth-cas', '~> 1.1.1'

# LDAP
gem 'net-ldap', '~> 0.16.1'

# dotenv - For storing production configuration parameters
gem 'dotenv-rails', '~> 2.1.1'

# clipboard - Uses clipboard.js to provide "Copy to Clipboard" functionality
gem 'clipboard-rails', '~>1.7.1'

# Pagination
gem 'will_paginate', '~> 3.1.0'
gem 'will_paginate-bootstrap', '~> 1.0.0'

# Table sorting
gem 'ransack', '~> 1.8.3'

# Used by Rake tasks to generate sample data
gem 'faker', '~> 1.8'

gem 'http', '~> 2.2.2'

# RFC-complient URI and URI template handling
gem 'addressable', '~> 2.5'

gem 'pg'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'solr_wrapper', '>= 0.3'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

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

gem 'rsolr', '~> 1.0'

gem "sparql-client", "~> 3.0"

gem 'stomp'
