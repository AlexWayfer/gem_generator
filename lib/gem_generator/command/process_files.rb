# frozen_string_literal: true

require_relative 'process_files/render_variables'

module GemGenerator
	## Main CLI command for Gem Generator
	class Command < ProjectGenerator::Command
		## Private instance methods for processing template files (copying, renaming, rendering)
		module ProcessFiles
			RENAME_FILES_PLACEHOLDERS = {
				name: 'gem_name',
				path: 'gem_path'
			}.freeze

			private

			def initialize_render_variables
				self.class::RenderVariables.new name, namespace, indentation, @summary
			end
		end
	end
end
