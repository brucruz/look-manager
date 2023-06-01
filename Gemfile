source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"
gem "rails", "~> 7.0.4", ">= 7.0.4.3"

# gem 'bcrypt_pbkdf', '>= 1.0', '< 2.0'
gem "bootsnap", require: false
# gem 'chromedriver-helper'
gem "cssbundling-rails"
gem "devise"
# gem 'ed25519', '>= 1.2', '< 2.0'
gem "jbuilder"
gem "jsbundling-rails"
# gem 'net-ssh', '>= 6.0.2'
gem 'tanakai'
gem "pg", "~> 1.1"
gem "puma", "~> 5.0"
# gem 'rbnacl', '< 5.0', :require => false                                                                                                                                                                
# gem 'rbnacl-libsodium', :require => false
gem "sprockets-rails"
gem "stimulus-rails"
gem "turbo-rails"
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem 'dotenv-rails'
end

group :development do
  gem 'bcrypt_pbkdf', '~> 1.1'
  gem 'capistrano', '~> 3.17'
  gem 'capistrano-rails', '~> 1.6', '>= 1.6.2'
  gem 'capistrano-passenger', '~> 0.2.1'
  gem 'capistrano-rbenv', '~> 2.2'
  gem 'ed25519', '~> 1.3'
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end
