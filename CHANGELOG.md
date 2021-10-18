# Changelog

## Unreleased

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
