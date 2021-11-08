# frozen_string_literal: true

require 'bundler'
require 'project_generator'

require_relative 'command/process_files'

## https://github.com/mdub/clamp#allowing-options-after-parameters
Clamp.allow_options_after_parameters = true

module GemGenerator
	## Main CLI command for Gem Generator
	class Command < ProjectGenerator::Command
		include ProcessFiles

		option ['-n', '--namespace'], 'NAME', 'use NAME as repository namespace'

		def execute
			check_target_directory

			## Prevent error like '"FIXME" or "TODO" is not a description' for `bundle install`
			@summary = ask_for_summary

			refine_template_parameter if git?

			process_files

			install_dependencies

			initialize_git

			FileUtils.rm_r @git_tmp_dir if git?

			done
		end

		private

		def ask_for_summary
			require 'readline'

			puts 'Please, write a summary for the gem:'

			result = Readline.readline('> ', true)

			puts <<~TEXT

				Thank you! You can write more detailed description later for `spec.description` and `README.md`.

			TEXT

			## Give a time to read the hint about description
			# sleep 3

			result
		end

		def install_dependencies
			puts 'Installing dependencies...'

			Dir.chdir name do
				## Helpful for specs of templates, probably somewhere else
				Bundler.with_unbundled_env do
					system 'bundle update'
				end

				system 'npm install' if File.exist? 'package.json'
			end
		end
	end
end
