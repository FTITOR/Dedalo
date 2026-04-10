# Dedalo

[![Hex.pm](https://img.shields.io/hexpm/v/dedalo.svg)](https://hex.pm/packages/dedalo) 
[![Build Status](https://github.com/FTITOR/Dedalo/actions/workflows/elixir.yml/badge.svg)](https://github.com/FTITOR/Dedalo/actions/workflows/elixir.yml)
[![Codecov](https://img.shields.io/codecov/c/github/FTITOR/Dedalo.svg)](https://codecov.io/gh/FTITOR/Dedalo)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Hex.pm](https://img.shields.io/hexpm/dt/dedalo.svg)](https://hex.pm/packages/dedalo)

## Installation

The package can be installed by adding `dedalo` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:dedalo, "~> 0.1.0"}
  ]
end
```

## How to use

`Dedalo` is a mix tool to build, link and sync the base configuration of LLMs
(agents) such as Claude, Gemini, Cursor, etc., for Elixir projects
using a single source of truth file as reference.

`dedalo` uses a single file to build and link LLM structure from a well-defined
YAML file, based on a pre-configured Elixir LLM development environment.

In order to work with a supported LLM provide the correct one:

```
* claude
* gemini
```

Then provide a path to the yml config file, if ok then results will be available
at LLM dir.

## Example

The next example will port the yml to the claude settings file, if no path default
will be used: `.agents/conf.yaml`

```
mix dedalo claude --path .agents/conf.yml 
```

## Portable escript

If you plan to use as a script just build:

```
mix escript.build
```

This will create an executable and can be used as a single script:

```
./dedalo claude --path .agents/conf.yml
```
