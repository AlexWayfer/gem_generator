# frozen_string_literal: true

require_relative 'lib/gem_generator/version'

Gem::Specification.new do |spec|
	spec.name        = 'gem_generator'
	spec.version     = GemGenerator::VERSION
	spec.authors     = ['Alexander Popov']
	spec.email       = ['alex.wayfer@gmail.com']

	spec.summary     = 'Generator for gems'
	spec.description = <<~DESC
		Generator for gems.
	DESC
	spec.license = 'MIT'

	spec.required_ruby_version = '>= 2.6', '< 4'

	github_uri = "https://github.com/AlexWayfer/#{spec.name}"

	spec.homepage = github_uri

	spec.metadata = {
		'rubygems_mfa_required' => 'true',
		'bug_tracker_uri' => "#{github_uri}/issues",
		'changelog_uri' => "#{github_uri}/blob/v#{spec.version}/CHANGELOG.md",
		# 'documentation_uri' => "http://www.rubydoc.info/gems/#{spec.name}/#{spec.version}",
		'homepage_uri' => spec.homepage,
		'source_code_uri' => github_uri
		# 'wiki_uri' => "#{github_uri}/wiki"
	}

	files = %w[
		lib/**/*.rb
		template/**/*
		README.md
		LICENSE.txt
		CHANGELOG.md
	]
	spec.files = Dir.glob "{#{files.join(',')}}", File::FNM_DOTMATCH
	spec.bindir = 'exe'
	spec.executables.concat %w[gem_generator]

	spec.add_runtime_dependency 'bundler', '~> 2.0'
	spec.add_runtime_dependency 'gorilla_patch', '~> 4.0'
	spec.add_runtime_dependency 'project_generator', '~> 0.2.0'

	spec.add_development_dependency 'pry-byebug', '~> 3.9'

	spec.add_development_dependency 'inifile', '~> 3.0'

	spec.add_development_dependency 'bundler-audit', '~> 0.9.0'

	spec.add_development_dependency 'gem_toys', '~> 0.12.1'
	spec.add_development_dependency 'toys', '~> 0.13.1'

	spec.add_development_dependency 'ffaker', '~> 2.19'
	spec.add_development_dependency 'rspec', '~> 3.9'
	spec.add_development_dependency 'simplecov', '~> 0.21.0'
	spec.add_development_dependency 'simplecov-cobertura', '~> 2.1'

	spec.add_development_dependency 'rubocop', '~> 1.29.0'
	spec.add_development_dependency 'rubocop-performance', '~> 1.0'
	spec.add_development_dependency 'rubocop-rspec', '~> 2.0'
end
