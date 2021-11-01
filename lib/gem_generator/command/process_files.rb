# frozen_string_literal: true

require_relative 'process_files/render_variables'

module GemGenerator
	## Main CLI command for Gem Generator
	class Command < Clamp::Command
		## Private instance methods for processing template files (copying, renaming, rendering)
		module ProcessFiles
			private

			def process_files
				copy_files

				begin
					@render_variables = RenderVariables.new name, namespace, indentation, @summary

					rename_files

					render_files
				rescue SystemExit => e
					FileUtils.rm_r @directory
					raise e
				end
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

					## Rename template file
					File.rename template_file, real_pathname

					## Update file content
					File.write real_pathname, content
				end
			end
		end

		private_constant :ProcessFiles
	end
end
