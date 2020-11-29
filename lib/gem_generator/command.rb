# frozen_string_literal: true

require 'clamp'
require 'erb'
require 'fileutils'
require 'gorilla_patch/inflections'
require 'pathname'
require 'yaml'

module GemGenerator
	## Main CLI command for Gem Generator
	class Command < Clamp::Command
		parameter 'NAME', 'name of a new gem'

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

		using GorillaPatch::Inflections

		def assign_project_variables
			@project_name = name
			@project_path = @project_name.tr('-', '/')
			@project_module = @project_path.camelize
			@project_modules = @project_module.split('::')
			@project_version_constant = "#{@project_module}::VERSION"
			@project_title = @project_name.split(/[-_]/).map(&:camelize).join(' ')

			assign_project_variables_from_config
		end

		def assign_project_variables_from_config
			load_config

			project_github_namespace = @config.fetch :github_namespace
			@project_github_path = "#{project_github_namespace}/#{@project_name}"
			@project_github_url = "https://github.com/#{@project_github_path}"
			@project_author_name = @config.fetch :author_name, `git config --get user.name`.chomp
			@project_author_email = @config.fetch :author_email, `git config --get user.email`.chomp
		end

		CONFIG_FILE_NAME = '.gem_generator.y{a,}ml'

		def load_config
			config_file = find_config_file

			unless config_file
				abort <<~TEXT
					You have to create `#{CONFIG_FILE_NAME}` file, for example in home directory.
					Check the README.
				TEXT
			end

			@config = YAML.load_file config_file
		end

		def find_config_file
			config_lookup_directory = Dir.getwd

			until (
				config_file = Dir.glob(
					File.join(config_lookup_directory, CONFIG_FILE_NAME), File::FNM_DOTMATCH
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
