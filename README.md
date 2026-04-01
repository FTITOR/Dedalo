# Dedalo

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `dedalo` to your list of dependencies in `mix.exs`:

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
