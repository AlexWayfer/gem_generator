# frozen_string_literal: true

require 'pry-byebug'

require 'ffaker'

require 'simplecov'

if ENV['CI']
	require 'simplecov-cobertura'
	SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
end

SimpleCov.start

RSpec.configure do |config|
	## Allows RSpec to persist some state between runs in order to support
	## the `--only-failures` and `--next-failure` CLI options. We recommend
	## you configure your source control system to ignore this file.
	config.example_status_persistence_file_path = "#{__dir__}/examples.txt"
end

RSpec::Matchers.define :include_lines do |expected_lines|
	match do |actual_text|
		expected_lines.all? do |expected_line|
			actual_text.lines.any? do |actual_line|
				actual_line.strip == expected_line.strip
			end
		end
	end

	diffable
end

RSpec::Matchers.define_negated_matcher :not_ending_with, :ending_with
RSpec::Matchers.define_negated_matcher :not_include, :include
RSpec::Matchers.define_negated_matcher :not_include_lines, :include_lines
RSpec::Matchers.define_negated_matcher :not_match, :match
RSpec::Matchers.define_negated_matcher :not_output, :output

require_relative '../lib/gem_generator/command'
