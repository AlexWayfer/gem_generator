# frozen_string_literal: true

require 'pry-byebug'

require 'ffaker'

require 'simplecov'

if ENV['CI']
	require 'simplecov-cobertura'
	SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
end

SimpleCov.start

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
