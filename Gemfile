# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rails', '8.1.1'

gem 'bootsnap', require: false
gem 'iconmap-rails'
gem 'importmap-rails'
gem 'jbuilder'
gem 'kamal', require: false
gem 'pg', '~> 1.6'
gem 'propshaft'
gem 'puma'
gem 'solid_cable'
gem 'solid_cache'
gem 'solid_queue'
gem 'stimulus-rails'
gem 'tailwindcss-rails'
gem 'thruster', require: false
gem 'turbo-rails'

gem 'inline_svg' # Keep after propshaft. Ref: jamesmartin/inline_svg#151

gem 'openssl' # TODO: remove when rails/importmap-rails#318 will be fixed

group :development, :test do
  gem 'brakeman', require: false
  gem 'byebug', platforms: %i[mri windows]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'i18n-tasks', require: false
  gem 'pry'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'readline' # TODO: Remove when deivid-rodriguez/pry-byebug#460 will be fixed
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-capybara', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rspec_rails', require: false
end

group :development do
  gem 'annotaterb', require: false
  gem 'rack-mini-profiler'
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'email_spec'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'simplecov-lcov', require: false
  gem 'webmock', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]
