source "https://rubygems.org"

gemspec

ruby '2.0.0', engine: 'jruby', engine_version: '1.7.15'

group :development, :test do
  gem 'rosette-datastore-memory', github: 'rosette-proj/rosette-datastore-memory', branch: 'remaining_ds_methods'
  gem 'activemodel', '~> 3.2.20'
  gem 'pry-nav'
  gem 'rake'
  gem 'repo-fixture'
end

group :test do
  gem 'simplecov'
  gem 'jbundler'
  gem 'rspec'
end
