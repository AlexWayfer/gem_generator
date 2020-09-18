# Gem Generator

[![Cirrus CI - Base Branch Build Status](https://img.shields.io/cirrus/github/AlexWayfer/gem_generator?style=flat-square)](https://cirrus-ci.com/github/AlexWayfer/gem_generator)
[![Codecov branch](https://img.shields.io/codecov/c/github/AlexWayfer/gem_generator/master.svg?style=flat-square)](https://codecov.io/gh/AlexWayfer/gem_generator)
[![Code Climate](https://img.shields.io/codeclimate/maintainability/AlexWayfer/gem_generator.svg?style=flat-square)](https://codeclimate.com/github/AlexWayfer/gem_generator)
[![Depfu](https://img.shields.io/depfu/AlexWayfer/gem_generator?style=flat-square)](https://depfu.com/repos/github/AlexWayfer/gem_generator)
[![Inline docs](https://inch-ci.org/github/AlexWayfer/gem_generator.svg?branch=master)](https://inch-ci.org/github/AlexWayfer/gem_generator)
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

At first, you have to create a config file, `.gem_generator.yaml` (or `.yml`) like this:

```yaml
:github_namespace: AlexWayfer

## These options are not required and have defaults from `git`
# :author_name: Alexander Popov
# :author_email: alex.wayfer@gmail.com
```

Gem Generator will look for it in each directory from current to the root,
so the common place for it in the home directory, but you can redefine it,
for example, in some directory for work projects.

Then just execute:

```sh
gem_generator name_of_a_new_gem
```

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
