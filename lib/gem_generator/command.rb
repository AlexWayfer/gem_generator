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

		option ['-n', '--namespace'], 'NAME', 'use NAME as repository namespace'

		attr_reader(
			:path, :title, :modules, :version_constant, :github_path, :github_uri,
			:author_name, :author_email
		)

		def execute
			@directory = File.expand_path name

			## Prevent error like '"FIXME" or "TODO" is not a description' for `bundle install`
			summary = ask_for_summary

			@render_variables = RenderVariables.new name, namespace, summary

			copy_files

			rename_files

			render_files

			initialize_git

			install_dependencies

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

			FileUtils.cp_r "#{__dir__}/../../template", @directory
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
				real_pathname = Pathname.new(template_file).sub_ext('')
				content = ERB.new(File.read(template_file)).result(@render_variables.get_binding)
				File.write real_pathname, content
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
