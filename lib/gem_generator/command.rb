# frozen_string_literal: true

require 'bundler'
require 'clamp'
require 'erb'
require 'fileutils'
require 'pathname'
require 'tmpdir'

require_relative 'command/process_files'

## https://github.com/mdub/clamp#allowing-options-after-parameters
Clamp.allow_options_after_parameters = true

module GemGenerator
	## Main CLI command for Gem Generator
	class Command < Clamp::Command
		include ProcessFiles

		parameter 'NAME', 'name of a new gem'
		parameter 'TEMPLATE', 'template path of a new gem'

		option ['-n', '--namespace'], 'NAME', 'use NAME as repository namespace'
		option ['-i', '--indentation'], 'TYPE', 'type of indentation (tabs or spaces)',
			default: 'tabs' do |value|
				## TODO: Add something like `:variants` to Clamp
				unless %w[tabs spaces].include? value
					raise ArgumentError, 'Only `tabs` or `spaces` values acceptable'
				end

				value
			end

		option '--git', :flag, 'use TEMPLATE as GitHub path (clone and generate from it)',
			default: false

		attr_reader(
			:path, :title, :modules, :version_constant, :github_path, :github_uri,
			:author_name, :author_email
		)

		def execute
			@directory = File.expand_path name

			signal_usage_error 'the target directory already exists' if Dir.exist? @directory

			## Prevent error like '"FIXME" or "TODO" is not a description' for `bundle install`
			@summary = ask_for_summary

			refine_template_parameter if git?

			process_files

			install_dependencies

			## If there is no `gem_generator` config — `render` asks `git config`
			## Also do `git add .` after all renders
			initialize_git

			FileUtils.rm_r @git_tmp_dir if git?

			puts 'Done.'

			puts <<~HELP
				To checkout into a new directory:
					cd #{name}
			HELP
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

		def refine_template_parameter
			@git_tmp_dir = Dir.mktmpdir
			`git clone -q https://github.com/#{template}.git #{@git_tmp_dir}`
			self.template = File.join @git_tmp_dir, 'template'
		end

		def initialize_git
			puts 'Initializing git...'

			Dir.chdir name do
				system 'git init'
				system 'git add .'
			end
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
