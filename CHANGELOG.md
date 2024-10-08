# Changelog

## Unreleased

## 0.5.0 (2024-08-27)

*   Update `project_generator` dependency.

*   Improve specs for different indentation.

*   Add Ruby 3.2 and 3.3 to CI.

*   Improve documentation.

*   Improve Cirrus CI configuration.

*   Lock development dependencies versions more strict.

*   Update development dependencies.

*   Resolve new RuboCop offenses.

*   Switch from Depfu to Renovate.

## 0.4.0 (2022-10-21)

*   Drop Ruby 2.6 and 2.7 support.
*   Add Ruby 3.1 for CI.
*   Update dependencies.
*   Change RSpec output format to `doc`.

## 0.3.2 (2021-11-10)

*   Update `project_generator`.
    Add custom parameters.

## 0.3.1 (2021-11-07)

*   Require runtime dependencies.

## 0.3.0 (2021-11-01)

*   Install Bundler template dependencies from unbundled environment.
    It should fix issues with templates specs, [example](https://github.com/lostisland/faraday-middleware-template/pull/3).
*   Speed up tests about `--git` option.
*   Update development dependencies.

## 0.2.0 (2021-10-18)

*   Add `--git` option.
    It allows you to use `TEMPLATE` parameter as GitHub path to automatically clone the repo
    (into `/tmp` directory) and use its nested `template/` directory as a template.

*   Add `author_name_string`.
    Sometimes names include apostrophes, we should catch these cases.

*   Improve usage documentation in README.

*   Add instructions about templates to README.

*   Remove Codecov token from Cirrus CI.
    It should support tokenless uploads.

*   Disable GitHub artifacts for RSpec.

*   Update development dependencies.

*   Remove docs badge from README.

## 0.1.0 (2021-10-05)

*   Initial release.
