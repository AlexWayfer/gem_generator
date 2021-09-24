# frozen_string_literal: true

require 'clamp'
require 'erb'
require 'fileutils'
require 'pathname'

require_relative 'render_variables'

module GemGenerator
	## Main CLI command for Gem Generator
	class Command < Clamp::Command
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

		attr_reader(
			:path, :title, :modules, :version_constant, :github_path, :github_uri,
			:author_name, :author_email
		)

		def execute
			@directory = File.expand_path name

			signal_usage_error 'the target directory already exists' if Dir.exist? @directory

			## Prevent error like '"FIXME" or "TODO" is not a description' for `bundle install`
			summary = ask_for_summary

			@render_variables = RenderVariables.new name, namespace, indentation, summary

			copy_files

			rename_files

			render_files

			install_dependencies

			## If there is no `gem_generator` config — `render` asks `git config`
			## Also do `git add .` after all renders
			initialize_git

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
			sleep 3

			result
		end

		def copy_files
			puts 'Copying files...'

			FileUtils.cp_r template, @directory

			FileUtils.rm_rf "#{@directory}/.git"
		end

		def rename_files
			puts 'Renaming files...'

			{ 'gem_name' => @render_variables.name, 'gem_path' => @render_variables.path }
				.each do |template_name, real_name|
					Dir["#{@directory}/**/*#{template_name}*"].each do |file_name|
						new_file_name =
							@directory + file_name.delete_prefix(@directory).gsub(template_name, real_name)

						FileUtils.mkdir_p File.dirname new_file_name

						File.rename file_name, new_file_name
					end
				end
		end

		def render_files
			puts 'Rendering files...'

			Dir.glob("#{@directory}/**/*.erb", File::FNM_DOTMATCH).each do |template_file|
				## Read a template file content and render it
				content =
					ERB.new(File.read(template_file), trim_mode: '-').result(@render_variables.get_binding)

				## Replace tabs with spaces if necessary
				content.gsub!(/^\t+/) { |tabs| '  ' * tabs.count("\t") } if indentation == 'spaces'

				## Render variables in file name
				real_pathname = Pathname.new(template_file).sub_ext('')

				## Save rendered file
				File.write real_pathname, content

				## Remove original template file
				FileUtils.rm template_file
			end
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
				system 'bundle update'

				system 'npm install'
			end
		end
	end
end
