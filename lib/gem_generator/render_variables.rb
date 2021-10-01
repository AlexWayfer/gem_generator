# frozen_string_literal: true

require 'yaml'
require 'memery'
require 'gorilla_patch/blank'
require 'gorilla_patch/inflections'

module GemGenerator
	## Class for a single object which should be a scope in render
	class RenderVariables
		include Memery

		using GorillaPatch::Blank
		using GorillaPatch::Inflections

		attr_reader :name, :indentation, :summary

		def initialize(name, namespace_option, indentation, summary)
			@name = name
			@namespace_option = namespace_option
			@indentation = indentation
			@summary = summary
		end

		## `public :binding` and `send :binding` return caller binding
		## This is from ERB documentation: https://ruby-doc.org/core-2.7.2/Binding.html
		# rubocop:disable Naming/AccessorMethodName
		def get_binding
			binding
		end
		# rubocop:enable Naming/AccessorMethodName

		memoize def summary_quotes
			summary.include?("'") ? '"' : "'"
		end

		memoize def description
			summary.match?(/[.?!]$/) ? summary : "#{summary}."
		end

		memoize def path
			name.tr('-', '/')
		end

		memoize def title
			name.split(/[-_]/).map(&:camelize).join(' ')
		end

		memoize def modules
			module_name.split('::')
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

		private

		memoize def module_name
			path.camelize
		end

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
