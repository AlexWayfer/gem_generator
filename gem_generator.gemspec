# frozen_string_literal: true

Gem::Specification.new do |spec|
	spec.name        = 'gem_generator'
	spec.version     = '0.1.0'
	spec.authors     = ['Alexander Popov']
	spec.email       = ['alex.wayfer@gmail.com']

	spec.summary     = 'Generator for gems'
	spec.description = <<~DESC
		Generator for gems.
	DESC
	spec.license = 'MIT'

	spec.required_ruby_version = '>= 2.5'

	source_code_uri = 'https://github.com/AlexWayfer/gem_generator'

	spec.homepage = source_code_uri

	spec.metadata['source_code_uri'] = source_code_uri

	spec.metadata['homepage_uri'] = spec.homepage

	# spec.metadata['changelog_uri'] =
	# 	'https://github.com/AlexWayfer/gem_generator/blob/master/CHANGELOG.md'

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

	spec.add_runtime_dependency 'clamp', '~> 1.3'

	spec.add_development_dependency 'pry-byebug', '~> 3.9'

	spec.add_development_dependency 'bundler', '~> 2.0'
	spec.add_development_dependency 'gem_toys', '~> 0.4.0'
	spec.add_development_dependency 'toys', '~> 0.11.0'

	# spec.add_development_dependency 'codecov', '~> 0.2.1'
	# spec.add_development_dependency 'rspec', '~> 3.9'
	# spec.add_development_dependency 'simplecov', '~> 0.18.0'

	spec.add_development_dependency 'rubocop', '~> 1.0.0'
	spec.add_development_dependency 'rubocop-performance', '~> 1.0'
	spec.add_development_dependency 'rubocop-rspec', '~> 1.43'
end
