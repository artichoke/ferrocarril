# ferrocarril

[![CircleCI](https://circleci.com/gh/artichoke/ferrocarril.svg?style=svg)](https://circleci.com/gh/artichoke/ferrocarril)

ferrocarril aims to embed a [Ruby on Rails](https://github.com/rails/rails) web
application that talks to an external MySQL database in Rust and serve the app
with [Rocket](https://rocket.rs/).

_ferrocarril_ means _railway_ in Spanish and sounds like _ferrous_ which means
_containing iron_.

## hubris

The [hubris crate](/hubris) runs a [`Sinatra::Base`](http://sinatrarb.com/) echo
server with [Nemesis](/nemesis).

### Usage

```bash
HUBRIS_LOG=info cargo run --bin hubris
```

Then, open `http://localhost:8000` on your browser.

### Features

- Utilizes a Rust implenentation of
  [`Regexp` and `MatchData`](/mruby/src/extn/core/regexp.rs).
- Utilizes a stack-based synchronous implementation of
  [`Thread`](/mruby/src/extn/core/thread.rb).
- Utilizes a complete implementation of Ruby 2.6.3
  [`String`](https://ruby-doc.org/core-2.6.3/String.html) API that uses a hybrid
  of mruby C, [Ruby](/mruby/src/extn/core/string.rb), and
  [Rust](/mruby/src/extn/core/string.rs).
- Utilizes implementations of Ruby standard library packages customized for
  mruby, including `delegate`, `forwardable`, `json`, `monitor`, `ostruct`,
  `set`, `strscan`, and `uri`.
- Utilizes
  [patched versions of Sinatra and its dependencies](/mruby-gems/src/rubygems/).

## foolsgold

The [foolsgold crate](/foolsgold) is an early attempt to achieve the goal of a
Rust-backed Ruby web application.

### Usage

```bash
FOOLSGOLD_LOG=info cargo run --bin foolsgold
```

Then, open `http://localhost:8000` on your browser.

### Features

- Embeds a safe [interpreter](/mruby) that wraps
  [generated C bindings](/mruby-sys) for
  [mruby](https://github.com/mruby/mruby).
- Implements a [web application server](/nemesis) similar to
  [Thin](https://github.com/macournoyer/thin) that supports shared nothing and
  prefork execution modes.
- Loads [pure Ruby sources](/foolsgold/ruby/lib) into the interpreter's
  [virtual filesystem](/mruby-vfs) such that Ruby code can require them.
- Defines [classes and modules in Rust](/foolsgold/src/foolsgold.rs) and loads
  them into the [virtual filesystem](/mruby-vfs) such that Ruby code can require
  them.
- [Shares Rust objects across mruby interpreter instances](https://github.com/artichoke/ferrocarril/blob/2144cf230360e18937664393b4f0e245718386a1/foolsgold/src/foolsgold.rs#L90-L110).
- Defines Ruby classes whose
  [instances are backed by Rust structs](/mruby/tests/manual.rs).
- [Bridges Rust and Ruby](/nemesis/src/handler.rs) by converting a
  [Rack-compatible response](/nemesis/ruby/lib/nemesis/response.rb) into a
  [Rocket response](https://rocket.rs/v0.4/guide/responses/#responses).

## REPL

Crate [mruby-bin](/mruby-bin) provides an `rirb` executable that is an
[IRB](https://en.wikipedia.org/wiki/Interactive_Ruby_Shell) shell and REPL for
the [mruby interpreter](/mruby) in this workspace. `rirb` aims to load every
extension to mruby made by this workspace in addition to all gems in
[the gems crate](/mruby-gems).

### Usage

```bash
cargo run --bin rirb
```

## Contributing

There is a lot to build! If you'd like to help out, take a look at the
[open issues](https://github.com/artichoke/ferrocarril/issues). Tickets that are
tagged with
[_good first issue_](https://github.com/artichoke/ferrocarril/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22)
might be a good introduction to the codebase.

### Setup

A ferrocarril development environment has several dependencies.
[Setup your development environment](/guide/development-setup.md).

### Code Overview

To familiarize yourself with the code in this workspace, consider reviewing
these source files:

| File                                          | Purpose                                                                | Learning Objective                                      |
| --------------------------------------------- | ---------------------------------------------------------------------- | ------------------------------------------------------- |
| [manual.rs](/mruby/tests/manual.rs)           | [mruby crate](/mruby) integration test                                 | Define Rust-backed Ruby sources                         |
| [extn::regexp](/mruby/src/extn/core/regexp)   | [`Regexp`](https://ruby-doc.org/core-2.6.3/Regexp.html) implementation | Implement a Ruby Core class with a mix of Rust and Ruby |
| [nemesis.rs](nemesis/src/rubygems/nemesis.rs) | [nemesis crate](/nemesis) Ruby runtime                                 | Define a [Gem](mruby-gems/src/lib.rs)                   |
| [ffi_tests.rs](/mruby-sys/src/ffi_tests.rs)   | C API test suite                                                       | Manipulate an interpreter with the C API                |
| [repl.rs](/mruby-bin/src/repl.rs)             | REPL loop for `rirb`                                                   | Eval code on an interpreter and handle errors           |

### Known Missing Features

#### Core

mruby does not implement all
[Ruby 2.6 core classes](https://ruby-doc.org/core-2.6.3/).

Required classes include (at least):

- `File`
- `IO`
- `Regexp`

#### Standard Library

mruby does not implement any of the
[Ruby 2.6 standard library](https://ruby-doc.org/stdlib-2.6.3/).

See the stdlib tracking ticket
([GH-8](https://github.com/artichoke/ferrocarril/issues/8)) for more details.

#### Gems

Rails requires lots of gems. This workspace maintains a
[registry of vendored gems](/mruby-gems). To support the goal of running Rails,
this crate [identifies dependencies](/mruby-gems/Gemfile.lock),
[vendors the gem sources](/mruby-gems/vendor), patches gems so they parse on
mruby, reimplements C extensions in Rust, and runs the tests for each gem.
