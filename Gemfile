source 'http://rubygems.org'

gem 'rails', '3.1.10'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'pg'
gem 'vpim', git: 'https://github.com/aceofsales/vpim.git'
gem 'devise'
gem 'unicorn'
gem 'haml'
gem "friendly_id", "~> 4.0.0.beta8"
gem 'airbrake'
gem 'newrelic_rpm'
gem 'delayed_job_active_record'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.1.4'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

group :development do
  gem 'tap'
  gem 'heroku'
  gem 'letter_opener'
end

group :test, :development do
  gem "rspec-rails", "~> 2.6"
  gem 'mysql2'
  gem 'turn', :require => false
  #gem 'ruby-debug19', :require => 'ruby-debug'
  gem 'capybara'
  gem 'fixture_builder'
  gem 'spork', '~> 0.9.0.rc'
  gem 'foreman'
end
