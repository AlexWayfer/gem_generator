# frozen_string_literal: true

require 'gorilla_patch/blank'

module GemGenerator
	## Main CLI command for Gem Generator
	class Command < ProjectGenerator::Command
		## Private instance methods for processing template files (copying, renaming, rendering)
		module ProcessFiles
			## Class for a single object which should be a scope in render
			class RenderVariables < ProjectGenerator::Command::ProcessFiles::RenderVariables
				using GorillaPatch::Blank

				attr_reader :summary

				def initialize(name, namespace_option, indentation, summary)
					super name, indentation

					@namespace_option = namespace_option
					@summary = summary

					## Call to be sure that this is checked before author fields
					github_namespace
				end

				memoize def summary_string
					quote = summary.include?("'") ? '"' : "'"
					"#{quote}#{summary}#{quote}"
				end

				memoize def description
					summary.match?(/[.?!]$/) ? summary : "#{summary}."
				end

				memoize def version_constant
					"#{module_name}::VERSION"
				end

				memoize def github_path
					"#{github_namespace}/#{name}"
				end

				memoize def github_namespace_uri
					"https://github.com/#{github_namespace}"
				end

				memoize def github_uri
					"https://github.com/#{github_path}"
				end

				EXAMPLE_VALUES = {
					name: 'My Name',
					email: 'my.email@example.com'
				}.freeze
				private_constant :EXAMPLE_VALUES

				%i[name email].each do |property|
					method_name = "author_#{property}"

					define_method method_name do
						result = config.dig(:author, property) || `git config --get user.#{property}`.chomp

						return result unless result.blank?

						abort <<~TEXT
							You have to specify project's author #{property}.
							You can use `git config user.#{property} "#{EXAMPLE_VALUES[property]}"`, or create a configuration file.
							Check the README.
						TEXT
					end

					memoize method_name
				end

				memoize def author_name_string
					quote = author_name.include?("'") ? '"' : "'"
					"#{quote}#{author_name}#{quote}"
				end

				private

				memoize def github_namespace
					result = @namespace_option || config[:namespace]

					return result unless result.blank?

					abort <<~TEXT
						You have to specify project's namespace on GitHub.
						You can use `--namespace` option, or create a configuration file.
						Check the README.
					TEXT
				end

				memoize def config
					config_file = find_config_file
					return {} unless config_file

					YAML.load_file config_file
				end

				def find_config_file
					config_lookup_directory = Dir.getwd

					until (
						config_file = Dir.glob(
							File.join(config_lookup_directory, '.gem_generator.y{a,}ml'), File::FNM_DOTMATCH
						).first
					) || config_lookup_directory == '/'
						config_lookup_directory = File.dirname config_lookup_directory
					end

					config_file
				end
			end
		end
	end
end
