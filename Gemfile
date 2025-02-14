# frozen_string_literal: true

source 'https://rubygems.org'

gemspec glob: '*.gemspec'

group :development do
	gem 'pry-byebug', '~> 3.9'

	gem 'inifile', '~> 3.0'

	gem 'gem_toys', '~> 0.14.0'
	gem 'toys', '~> 0.15.0'
end

group :audit do
	gem 'bundler-audit', '~> 0.9.0'
end

group :test do
	gem 'ffaker', '~> 2.19'
	gem 'rspec', '~> 3.9'
	gem 'simplecov', '~> 0.22.0'
	gem 'simplecov-cobertura', '~> 2.1'
end

group :lint do
	gem 'rubocop', '~> 1.72.0'
	gem 'rubocop-performance', '~> 1.23.0'
	gem 'rubocop-rspec', '~> 3.4.0'
end
