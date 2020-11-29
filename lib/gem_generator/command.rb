# frozen_string_literal: true

require 'clamp'
require 'erb'
require 'fileutils'
require 'gorilla_patch/blank'
require 'gorilla_patch/inflections'
require 'pathname'
require 'yaml'

module GemGenerator
	## Main CLI command for Gem Generator
	class Command < Clamp::Command
		parameter 'NAME', 'name of a new gem'

		option ['-n', '--namespace'], 'NAME', 'use NAME as repository namespace'

		def execute
			@directory = File.expand_path name

			assign_project_variables

			copy_files

			rename_files

			render_files

			puts 'Done.'

			puts <<~HELP
				To checkout into a new directory:
					cd #{name}
			HELP
		end

		private

		using GorillaPatch::Blank
		using GorillaPatch::Inflections

		def assign_project_variables
			@project_name = name
			@project_path = @project_name.tr('-', '/')
			@project_module = @project_path.camelize
			@project_modules = @project_module.split('::')
			@project_version_constant = "#{@project_module}::VERSION"
			@project_title = @project_name.split(/[-_]/).map(&:camelize).join(' ')

			@config = YAML.load_file find_config_file

			assign_project_repository_variables

			assign_project_author_variables
		end

		def assign_project_repository_variables
			project_github_namespace = namespace || @config[:namespace]

			if project_github_namespace.blank?
				abort <<~TEXT
					You have to specify project's namespace on GitHub.
					You can use `--namespace` option, or create a configuration file.
					Check the README.
				TEXT
			end

			@project_github_path = "#{project_github_namespace}/#{@project_name}"
			@project_github_url = "https://github.com/#{@project_github_path}"
		end

		def assign_project_author_variables
			@project_author_name = @config.fetch :author_name, `git config --get user.name`.chomp
			@project_author_email = @config.fetch :author_email, `git config --get user.email`.chomp

			return unless @project_author_name.blank? || @project_author_email.blank?

			abort <<~TEXT
				You have to specify project's author.
				You can use `git config --get user.name` and `user.email`, or create a configuration file.
				Check the README.
			TEXT
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

		def copy_files
			puts 'Copying files...'

			FileUtils.cp_r "#{__dir__}/../../template", @directory
		end

		def rename_files
			puts 'Renaming files...'

			{ 'gem_name' => @project_name, 'gem_path' => @project_path }
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
				content = ERB.new(File.read(template_file)).result(binding)
				File.write real_pathname, content
				FileUtils.rm template_file
			end
		end
	end
end
