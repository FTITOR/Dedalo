defmodule Dedalo.CLI do
  @moduledoc """
  `CLI` is the main module to use as a escript.

  This follows the same args as mix tool, please review docs in Mix Task.
  """

  @doc """
  Main fn for escript building.
  """
  def main(args), do: Mix.Tasks.Dedalo.run(args)
end
