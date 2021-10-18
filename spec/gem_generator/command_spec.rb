# frozen_string_literal: true

require 'gorilla_patch/deep_merge'
require 'inifile'

describe GemGenerator::Command do
	using GorillaPatch::DeepMerge

	describe '.run' do
		subject(:run) do
			described_class.run('gem_generator', args)
		end

		## I'd like to use `instance_double`, but it doesn't support `and_call_original`
		let(:command_instance) { described_class.new('gem_generator') }

		before do
			# allow(command_instance).to receive(:run).and_call_original
			allow(described_class).to receive(:new).and_return command_instance
		end

		context 'without gem name parameter' do
			let(:args) { [] }

			it do
				expect { run }.to raise_error(SystemExit).and output(
					/ERROR: parameter 'NAME': no value provided/
				).to_stderr
			end
		end

		context 'with gem name parameter' do
			let(:gem_name) { 'foo_bar' }
			let(:args) { [gem_name] }

			shared_examples 'target directory does not exist' do
				describe 'existing of target directory' do
					subject { Dir.exist? File.join(Dir.pwd, gem_name) }

					before do
						[
							'Copying files...',
							'Renaming files...',
							'Rendering files...'
						].each do |line|
							allow($stdout).to receive(:puts).with(line)
						end

						allow($stderr).to receive(:write).with(/#{<<~TEXT.chomp}/)
							You have to specify project's .+\\.
							You can use .+\\.
							Check the README\\.
						TEXT

						run
					rescue SystemExit
						## we want this exit, but inspecting another thing
					end

					it { is_expected.to be false }
				end
			end

			shared_context 'with supressing regular output' do
				before do
					[
						'Copying files...',
						'Renaming files...',
						'Rendering files...',
						'Installing dependencies...',
						'Initializing git...',
						'Done.',
						"To checkout into a new directory:\n\tcd foo_bar\n"
					].each do |line|
						allow($stdout).to receive(:puts).with(line)
					end
				end
			end

			context 'without template parameter' do
				it do
					expect { run }.to raise_error(SystemExit).and output(
						/ERROR: parameter 'TEMPLATE': no value provided/
					).to_stderr
				end
			end

			context 'with template parameter' do
				let(:args) { [*super(), template] }

				let(:gem_summary) { 'Foo bar gem' }

				before do
					allow($stdout).to receive(:puts).and_call_original

					allow($stdout).to receive(:puts).with('Please, write a summary for the gem:')
					allow(Readline).to receive(:readline).and_call_original
					allow(Readline).to receive(:readline).with('> ', true).and_return gem_summary
					allow($stdout).to receive(:puts).with(
						/Thank you! You can write more detailed description later/
					)

					allow(command_instance).to receive(:system).with('git init')
					allow(command_instance).to receive(:system).with('git add .')
					allow(command_instance).to receive(:system).with('bundle update')
					allow(command_instance).to receive(:system).with('npm install')
				end

				after do
					FileUtils.rm_r gem_name if Dir.exist? gem_name
				end

				shared_examples 'correct behavior with template' do
					shared_context 'with changing git user config' do |git_property|
						before do
							value = send("temp_git_#{git_property}")
							system "git config user.#{git_property} \"#{value}\""
						end

						after do
							system "git config --unset user.#{git_property}"
						end
					end

					shared_examples 'common correct system calls with all data' do
						specify do
							expect(command_instance).to have_received(:system).with('git init').once
						end

						specify do
							expect(command_instance).to have_received(:system).with('bundle update').once
						end
					end

					shared_examples 'common correct files with all data' do
						describe 'gem_name.gemspec.erb' do
							subject(:file_content) do
								File.read(File.join(Dir.pwd, gem_name, "#{gem_name}.gemspec"))
							end

							before do
								run ## parent subject with generation
							end

							let(:expected_lines) do
								[
									"require_relative 'lib/#{gem_name}/version'",
									"spec.name        = '#{gem_name}'",
									'spec.version     = FooBar::VERSION',
									"spec.authors     = [#{author_name_string}]",
									"spec.email       = ['#{author_email}']",
									"spec.summary     = #{gem_summary_string}",
									gem_description_string,
									"github_uri = \"https://github.com/#{namespace}/\#{spec.name}\""
								]
							end

							let(:author_name_string) do
								author_name_quotes = author_name.include?("'") ? '"' : "'"
								"#{author_name_quotes}#{author_name}#{author_name_quotes}"
							end

							context 'without dot in gem summary' do
								let(:gem_summary_string) do
									"#{gem_summary_quotes}#{gem_summary}#{gem_summary_quotes}"
								end

								let(:gem_description_string) { "#{gem_summary}." }

								context 'without single quotes in gem summary' do
									let(:gem_summary) { 'Foo bar gem' }
									let(:gem_summary_quotes) { "'" }

									it do
										expect(file_content).to include_lines expected_lines
									end
								end

								context 'with single quotes in gem summary' do
									let(:gem_summary) { "Foo bar's gem" }
									let(:gem_summary_quotes) { '"' }

									it do
										expect(file_content).to include_lines expected_lines
									end
								end
							end
						end

						describe 'CHANGELOG.md' do
							subject(:file_content) do
								File.read(File.join(Dir.pwd, gem_name, 'CHANGELOG.md'))
							end

							before do
								run ## parent subject with generation
							end

							let(:expected_lines) do
								[
									'# Changelog',
									'## Unreleased',
									'*   Initial release.'
								]
							end

							it do
								expect(file_content).to include_lines expected_lines
							end
						end

						describe '.editorconfig' do
							subject(:ini_file) do
								IniFile.load(File.join(Dir.pwd, gem_name, '.editorconfig')).to_h
							end

							before do
								run ## parent subject with generation
							end

							context 'with default indentation (tabs)' do
								let(:expected_values) do
									a_hash_including(
										'*' => a_hash_including(
											'indent_style' => 'tab',
											'indent_size' => 2
										)
									)
								end

								let(:not_expected_values) do
									a_hash_including(
										'*' => a_hash_including(
											'indent_style' => 'space'
										)
									)
								end

								it do
									expect(ini_file).to match(expected_values).and not_match(not_expected_values)
								end

								describe '.gemspec indentation' do
									subject(:file_content) do
										File.read(File.join(Dir.pwd, gem_name, "#{gem_name}.gemspec"))
									end

									it { is_expected.to match(/^\tspec.license = 'MIT'$/) }
									it { is_expected.not_to match(/^  /) }
								end
							end

							context 'with spaces indentation' do
								let(:args) do
									[*super(), '--indentation=spaces']
								end

								let(:expected_values) do
									a_hash_including(
										'*' => a_hash_including(
											'indent_style' => 'space',
											'indent_size' => 2
										)
									)
								end

								let(:not_expected_values) do
									a_hash_including(
										'*' => a_hash_including(
											'indent_style' => 'tab'
										)
									)
								end

								it do
									expect(ini_file).to match(expected_values).and not_match(not_expected_values)
								end

								describe '.gemspec indentation' do
									subject(:file_content) do
										File.read(File.join(Dir.pwd, gem_name, "#{gem_name}.gemspec"))
									end

									it { is_expected.to match(/^  spec.license = 'MIT'$/) }
									it { is_expected.not_to match(/^\t/) }
								end
							end
						end
					end

					shared_examples 'common correct behavior with all data' do
						describe 'output' do
							let(:expected_output_start) do
								## There is allowed prompt
								<<~OUTPUT
									Please, write a summary for the gem:

									Thank you! You can write more detailed description later for `spec.description` and `README.md`.

									Copying files...
									Renaming files...
									Rendering files...
									Installing dependencies...
									Initializing git...
								OUTPUT
							end

							let(:expected_output_end) do
								<<~OUTPUT
									Done.
									To checkout into a new directory:
										cd #{gem_name}
								OUTPUT
							end

							specify do
								expect { run }.to output(
									a_string_starting_with(expected_output_start)
										.and(ending_with(expected_output_end))
								).to_stdout_from_any_process.and not_output.to_stderr_from_any_process
							end
						end

						describe 'system calls' do
							include_context 'with supressing regular output'

							before do
								run
							end

							include_examples 'correct system calls with all data'
						end

						describe 'files' do
							include_context 'with supressing regular output'

							include_examples 'correct files with all data'
						end
					end

					shared_examples 'correct behavior without author name' do
						include_context 'with changing git user config', :name do
							let(:temp_git_name) { nil }
						end

						describe 'output' do
							let(:expected_output_start) do
								## There is allowed prompt
								<<~OUTPUT
									Please, write a summary for the gem:

									Thank you! You can write more detailed description later for `spec.description` and `README.md`.

									Copying files...
								OUTPUT
							end

							## There is some dependencies installation output

							let(:non_expected_output_end) do
								<<~OUTPUT
									Done.
									To checkout into a new directory:
										cd #{gem_name}
								OUTPUT
							end

							specify do
								expect { run }.to raise_error(SystemExit).and output(
									a_string_starting_with(expected_output_start)
										.and(not_ending_with(non_expected_output_end))
								).to_stdout.and output(<<~OUTPUT).to_stderr
									You have to specify project's author name.
									You can use `git config user.name "My Name"`, or create a configuration file.
									Check the README.
								OUTPUT
							end
						end

						include_examples 'target directory does not exist'
					end

					shared_examples 'correct behavior without author email' do
						include_context 'with changing git user config', :email do
							let(:temp_git_email) { nil }
						end

						context 'with author name from git' do
							include_context 'with changing git user config', :name do
								let(:temp_git_name) { FFaker::Name.name }
							end

							describe 'output' do
								let(:expected_output_start) do
									## There is allowed prompt
									<<~OUTPUT
										Please, write a summary for the gem:

										Thank you! You can write more detailed description later for `spec.description` and `README.md`.

										Copying files...
									OUTPUT
								end

								## There is some dependencies installation output

								let(:non_expected_output_end) do
									<<~OUTPUT
										Done.
										To checkout into a new directory:
											cd #{gem_name}
									OUTPUT
								end

								specify do
									expect { run }.to raise_error(SystemExit).and output(
										a_string_starting_with(expected_output_start)
											.and(not_ending_with(non_expected_output_end))
									).to_stdout.and output(<<~OUTPUT).to_stderr
										You have to specify project's author email.
										You can use `git config user.email "my.email@example.com"`, or create a configuration file.
										Check the README.
									OUTPUT
								end
							end

							include_examples 'target directory does not exist'
						end
					end

					shared_examples 'correct behavior without namespace' do
						describe 'output' do
							let(:expected_output_start) do
								## There is allowed prompt
								<<~OUTPUT
									Please, write a summary for the gem:

									Thank you! You can write more detailed description later for `spec.description` and `README.md`.

									Copying files...
								OUTPUT
							end

							## There is some dependencies installation output

							let(:non_expected_output_end) do
								<<~OUTPUT
									Done.
									To checkout into a new directory:
										cd #{gem_name}
								OUTPUT
							end

							specify do
								expect { run }.to raise_error(SystemExit).and output(
									a_string_starting_with(expected_output_start)
										.and(not_ending_with(non_expected_output_end))
								).to_stdout.and output(<<~OUTPUT).to_stderr
									You have to specify project's namespace on GitHub.
									You can use `--namespace` option, or create a configuration file.
									Check the README.
								OUTPUT
							end
						end

						include_examples 'target directory does not exist'
					end

					shared_examples 'when author names with apostrophe and without' do
						context 'when author name does not include apostrophe' do
							let(:author_name) { 'Erica Johns' }

							include_examples 'correct behavior with all data'
						end

						context 'when author name includes apostrophe' do
							let(:author_name) { "Lynda O'Kon" }

							include_examples 'correct behavior with all data'
						end
					end

					context 'without config file' do
						before do
							# render_variables_double = instance_double GemGenerator::RenderVariables
							# allow(render_variables_double).to receive(:find_config_file).and_return nil
							# allow(render_variables_double).to receive(anything).and_call_original
							#
							# allow(GemGenerator::RenderVariables).to receive(:new)
							#   .and_return render_variables_double

							allow(Dir).to receive(:glob).and_call_original
							allow(Dir).to(
								receive(:glob)
									.with(a_string_matching(%r{/\.gem_generator\.}), anything)
									.and_return([])
							)
						end

						context 'without namespace option' do
							include_examples 'correct behavior without namespace'
						end

						context 'with namespace option' do
							let(:namespace) { FFaker::Internet.user_name }
							let(:args) do
								[*super(), "--namespace=#{namespace}"]
							end

							context 'with author email from git' do
								let(:author_email) do
									FFaker::Internet.email
								end

								include_context 'with changing git user config', :email do
									let(:temp_git_email) { author_email }
								end

								context 'with author name from git' do
									include_context 'with changing git user config', :name do
										let(:temp_git_name) { author_name }
									end

									include_examples 'when author names with apostrophe and without'

									context 'with incorrect indentation option' do
										let(:args) do
											[*super(), '--indentation=foo']
										end

										let(:author_name) { 'Erica Johns' }

										specify do
											expect { run }.to(
												raise_error(SystemExit).and(
													not_output.to_stdout.and(
														output(<<~OUTPUT).to_stderr
															ERROR: option '--indentation': Only `tabs` or `spaces` values acceptable

															See: 'gem_generator --help'
														OUTPUT
													)
												)
											)
										end
									end
								end

								context 'without author name from git' do
									include_examples 'correct behavior without author name'
								end
							end

							context 'without author email from git' do
								include_examples 'correct behavior without author email'
							end
						end
					end

					context 'with config file' do
						around do |example|
							raise "There is should not be `#{config_file_name}`!" if File.exist? config_file_name

							File.write config_file_name, YAML.dump(config_file_content)
							example.run
						ensure
							File.delete config_file_name
						end

						let(:config_file_content) { {} }

						shared_examples 'correct behavior' do
							shared_examples 'correct behavior with namespace' do
								shared_examples 'correct behavior with author email' do
									context 'with author name in config file' do
										let(:config_file_content) do
											super().deep_merge(author: { name: author_name })
										end

										## It should be different and with lower priority
										include_context 'with changing git user config', :name do
											let(:temp_git_name) { FFaker::Name.name }
										end

										include_examples 'when author names with apostrophe and without'
									end

									context 'without author name in config file' do
										context 'with author name from git' do
											include_context 'with changing git user config', :name do
												let(:temp_git_name) { author_name }
											end

											include_examples 'when author names with apostrophe and without'
										end

										context 'without author name from git' do
											include_examples 'correct behavior without author name'
										end
									end
								end

								let(:namespace) { FFaker::Internet.user_name }

								context 'with author email in config file' do
									let(:config_file_content) do
										super().deep_merge(author: { email: author_email })
									end

									let(:author_email) { FFaker::Internet.email }

									## It should be different and with lower priority
									include_context 'with changing git user config', :email do
										let(:temp_git_email) { FFaker::Internet.email }
									end

									include_examples 'correct behavior with author email'
								end

								context 'without author email in config file' do
									context 'with author email from git' do
										let(:author_email) { FFaker::Internet.email }

										include_context 'with changing git user config', :email do
											let(:temp_git_email) { author_email }
										end

										include_examples 'correct behavior with author email'
									end

									context 'without author email from git' do
										include_examples 'correct behavior without author email'
									end
								end
							end

							context 'without namespace inside' do
								context 'without namespace option' do
									include_examples 'correct behavior without namespace'
								end

								context 'with namespace option' do
									let(:args) do
										[*super(), "--namespace=#{namespace}"]
									end

									include_examples 'correct behavior with namespace'
								end
							end

							context 'with namespace inside' do
								let(:config_file_content) do
									super().deep_merge(namespace: config_namespace)
								end

								let(:config_namespace) { namespace }
								let(:namespace) { FFaker::Internet.user_name }

								context 'without namespace option' do
									include_examples 'correct behavior with namespace'
								end

								context 'with namespace option' do
									let(:config_namespace) { FFaker::Internet.user_name }

									let(:args) do
										[*super(), "--namespace=#{namespace}"]
									end

									include_examples 'correct behavior with namespace'
								end
							end
						end

						context 'when file extension is `.yaml`' do
							let(:config_file_name) { '.gem_generator.yaml' }

							include_examples 'correct behavior'
						end

						context 'when file extension is `.yml`' do
							let(:config_file_name) { '.gem_generator.yml' }

							include_examples 'correct behavior'
						end
					end
				end

				context 'when this template is local (by default)' do
					let(:template) { "#{__dir__}/../support/example_template" }

					shared_examples 'correct system calls with all data' do
						include_examples 'common correct system calls with all data'

						context 'without `package.json` file' do
							specify do
								expect(command_instance).not_to have_received(:system).with('npm install')
							end
						end

						context 'with `package.json` file' do
							around do |example|
								if File.exist? "#{template}/package.json"
									raise 'Template should not contain `package.json` file'
								end

								FileUtils.touch "#{template}/package.json"
								example.run
								FileUtils.rm "#{template}/package.json"
							end

							specify do
								expect(command_instance).to have_received(:system).with('npm install').once
							end
						end
					end

					shared_examples 'correct files with all data' do
						include_examples 'common correct files with all data'

						describe 'bin/console.erb' do
							describe 'permissions' do
								subject(:file_permissions) do
									File.stat(File.join(Dir.pwd, gem_name, 'bin/console')).mode
								end

								let(:expected_permissions) do
									File.stat("#{template}/bin/console.erb").mode
								end

								before do
									run ## parent subject with generation
								end

								it { is_expected.to eq expected_permissions }
							end
						end
					end

					shared_examples 'correct behavior with all data' do
						include_examples 'common correct behavior with all data'
					end

					include_examples 'correct behavior with template'
				end

				context 'with `--git` option (for template)' do
					let(:template) { 'AlexWayfer/gem_template' }
					let(:args) { [*super(), '--git'] }

					shared_examples 'correct system calls with all data' do
						include_examples 'common correct system calls with all data'
					end

					shared_examples 'correct files with all data' do
						include_examples 'common correct files with all data'
					end

					shared_examples 'correct behavior with all data' do
						include_examples 'common correct behavior with all data'
					end

					include_examples 'correct behavior with template'
				end
			end
		end
	end
end
