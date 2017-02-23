source 'https://rubygems.org'

branch = ENV.fetch('SOLIDUS_BRANCH', 'master')
gem 'solidus', github: 'solidusio/solidus', branch: branch

if branch == 'master' || branch >= 'v2.0'
  gem 'rails-controller-testing', group: :test
else
  gem 'rails', '~> 4.2'
end

gem 'solidus_auth_devise'
gem 'searchkick', '~> 2.1'


group :development, :test do
  gem 'codeclimate-test-reporter', '~> 0.6', require: false
end

gemspec
