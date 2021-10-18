# Gem Generator

[![Cirrus CI - Base Branch Build Status](https://img.shields.io/cirrus/github/AlexWayfer/gem_generator?style=flat-square)](https://cirrus-ci.com/github/AlexWayfer/gem_generator)
[![Codecov branch](https://img.shields.io/codecov/c/github/AlexWayfer/gem_generator/main.svg?style=flat-square)](https://codecov.io/gh/AlexWayfer/gem_generator)
[![Code Climate](https://img.shields.io/codeclimate/maintainability/AlexWayfer/gem_generator.svg?style=flat-square)](https://codeclimate.com/github/AlexWayfer/gem_generator)
[![Depfu](https://img.shields.io/depfu/AlexWayfer/gem_generator?style=flat-square)](https://depfu.com/repos/github/AlexWayfer/gem_generator)
[![license](https://img.shields.io/github/license/AlexWayfer/gem_generator.svg?style=flat-square)](LICENSE.txt)
[![Gem](https://img.shields.io/gem/v/gem_generator.svg?style=flat-square)](https://rubygems.org/gems/gem_generator)

Gem for new gems generation.

It was created for myself, but you can suggest options for generation to adopt it for your usage.

## Installation

Install it globally:

```shell
gem install gem_generator
```

## Usage

### With local template

```sh
gem_generator --namespace=your_github_nickname name_of_a_new_gem path/to/template
```

### With GitHub template

```sh
gem_generator --namespace=your_github_nickname name_of_a_new_gem template_github_org/template_github_repo
```

Be aware: `gem_generator` uses `template/` directory from the GitHub repo, not the root one.

### Config file

You can create a config file, `.gem_generator.yaml` (or `.yml`) like this:

```yaml
## This can be overwriten via `--namespace` CLI option, config just as default
:namespace: AlexWayfer

## These options have defaults from `git config --get user.*`
# :author:
#   :name: Alexander Popov
#   :email: alex.wayfer@gmail.com
```

Gem Generator will look for it in each directory from current to the root,
so the common place for it in the home directory, but you can redefine it,
for example, in some directory for work projects.

## Template creation

Example of gem template you can see at [AlexWayfer/gem_template](https://github.com/AlexWayfer/gem_template).

Available paths:

| Path part  | Example of source             | Example of result                      |
| ---------- | ----------------------------- | -------------------------------------- |
| `gem_name` | `gem_name.gemspec`            | `faraday-my_middleware.gemspec`        |
| `gem_path` | `lib/gem_path/version.rb.erb` | `lib/faraday/my_middleware/version.rb` |

Any `*.erb` file will be rendered via [ERB](https://ruby-doc.org/stdlib/libdoc/erb/rdoc/ERB.html);
if you want an `*.erb` file as result — name it as `*.erb.erb` (even if there are no tags).

Available variables:

| Variable               | Example of result                                          |
| ---------------------- | ---------------------------------------------------------- |
| `name`                 | `faraday-my_middleware`                                    |
| `title`                | `Faraday My Middleware`                                    |
| `path`                 | `faraday/my_middleware`                                    |
| `module_name`          | `Faraday::MyMiddleware`                                    |
| `modules`              | `['Faraday', 'MyMiddleware']`                              |
| `version_constant`     | `Faraday::MyMiddleware::VERSION`                           |
| `summary`              | asked from user                                            |
| `summary_string`       | summary wrapped in `'` or `"`, depending on `'` inside     |
| `description`          | by default is `summary` with guaranteed dot at the end     |
| `indentation`          | `tabs` or `spaces`, as user specified by option            |
| `github_path`          | `AlexWayfer/faraday-my_middleware`                         |
| `github_namespace_uri` | `https://github.com/AlexWayfer`                            |
| `github_uri`           | `https://github.com/AlexWayfer/faraday-my_middleware`      |
| `author_name`          | `Alexander Popov`                                          |
| `author_name_string`   | author name wrapped in `'` or `"`, depending on `'` inside |
| `author_email`         | `alex.wayfer@gmail.com`                                    |

By default indentation is `tabs`, but if a template spaces-indented — option will not affect.
So, this option only for tabs-indented templates.

### Git templates

You can create public git-templates and then guide users to call
`gem_generator gem_game your_org/your_repo --git`, but be aware that `gem_generator` will look
for template inside `template/` directory to allow you having out-of-template README,
specs (for the template itself), anything else.

## Development

After checking out the repo, run `bundle install` to install dependencies.

Then, run `toys rspec` to run the tests.

To install this gem onto your local machine, run `toys gem install`.

To release a new version, run `toys gem release %version%`.
See how it works [here](https://github.com/AlexWayfer/gem_toys#release).

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/AlexWayfer/gem_generator).

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
