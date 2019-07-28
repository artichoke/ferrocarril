#!/usr/bin/env bash

set -euo pipefail
set -x

lint_ruby_sources() {
  pushd "$@" >/dev/null
  bundle install >/dev/null
  bundle exec rubocop -a
  popd >/dev/null
}

# Rust sources

## Format with rustfmt
cargo fmt
## Lint with Clippy
cargo clippy --all-targets --all-features
## Lint docs
cargo doc --no-deps --all

# Lint Ruby sources

## mruby::extn
lint_ruby_sources mruby/src/extn
## spec-runner
lint_ruby_sources spec-runner/src
## mruby bins
lint_ruby_sources mruby-bin/ruby
## nemesis
lint_ruby_sources nemesis/ruby
## foolsgold
lint_ruby_sources foolsgold/ruby
## hubris
lint_ruby_sources hubris/src

# C sources

## Format with clang-format
find . -type f \
  -and \( -name '*.h' -or -name '*.c' \) \
  -and -not -path '*vendor*' \
  -and -not -path '*target*' \
  -and -not -path '*node_modules*' \
  -and -not -path '*spec/ruby*' -print0 |
  xargs -0 yarn run clang-format -i

# Shell sources

## Format with shfmt
find . -type f \
  -and \( -name '*.sh' -or -name '*.bash' \) \
  -and -not -path '*vendor*' \
  -and -not -path '*target*' \
  -and -not -path '*node_modules*' \
  -and -not -path '*spec/ruby*' -print0 |
  xargs -0 shfmt -w -i 2

## Lint with shellcheck
find . -type f \
  -and \( -name '*.sh' -or -name '*.bash' \) \
  -and -not -path '*vendor*' \
  -and -not -path '*target*' \
  -and -not -path '*node_modules*' \
  -and -not -path '*spec/ruby*' -print0 |
  xargs -0 shellcheck

# Text sources (e.g. HTML, Markdown)

## Format with prettier
yarn run format-text
