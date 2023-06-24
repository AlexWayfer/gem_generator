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

	spec.required_ruby_version = '>= 3.0', '< 4'

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
	spec.executables.concat.push 'gem_generator'

	spec.add_runtime_dependency 'bundler', '~> 2.0'
	spec.add_runtime_dependency 'gorilla_patch', '~> 5.0'
	spec.add_runtime_dependency 'project_generator', '~> 0.3.0'
end
