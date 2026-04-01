defmodule Mix.Tasks.Dedalo do
  @moduledoc """
  `Dedalo` is a mix tool to build, link and sync the base configuration of LLMs
   (agents) such as Claude, Gemini, Cursor, etc., for Elixir projects 
   using a single source of truth file as reference.

  `dedalo` uses a single file to build and link LLM structure from a well-defined
  YAML file, based on a pre-configured Elixir LLM development environment.

  `How to use`

  In order to work with a supported LLM provide the correct one:

  ```
  * claude
  * gemini
  ```

  Then provide a path to the yml config file, if ok then results will be available
  at LLM dir.

  `Example`

  The next example will port the yml to the claude settings file, if no path default
  will be used: `.agents/conf.yaml`

  ```
  mix dedalo claude --path .agents/conf.yml 
  ```
  """
  use Mix.Task

  alias Dedalo.Claude

  @shortdoc "Build, link and sync LLM structure from an Elixir well-defined base."

  @supported_llms ["claude", "gemini"]
  @stricts [path: :string]
  @aliases [p: :path]
  @default_path ".agents/conf.yaml"
  @tags ["deny", "allow"]
  @security "security"

  @impl true
  def run([llm | options]) when llm in @supported_llms do
    {opts, _remaining_args, _invalid} =
      OptionParser.parse(options, strict: @stricts, aliases: @aliases)

    conf_file = Keyword.get(opts, :path, @default_path)

    conf_file
    |> File.exists?()
    |> case do
      true ->
        Mix.shell().info("📖 conf file found, processing ...")

        conf_file
        |> parse_file()
        |> build_llm_tool(llm)

      false ->
        Mix.shell().error("⚠️  missing conf file, please ensure file exists on the provided path.")
    end
  end

  def run(_) do
    Mix.shell().error("⚠️  no supported LLM, please execute mix help dedalo for more info.")
  end

  defp parse_file(file) do
    file
    |> YamlElixir.read_from_file()
    |> case do
      {:ok, conf} ->
        conf_sec = Map.get(conf, @security, %{})

        Enum.map(@tags, fn tag ->
          {String.to_atom(tag), Map.get(conf_sec, tag, %{})}
        end)

      {:error, reason} ->
        Mix.shell().error("⚠️  error while parsing conf file, reason #{inspect(reason)}")
        :err
    end
  end

  defp build_llm_tool(:err, _), do: :ok

  defp build_llm_tool(config, "claude") do
    Mix.shell().info("✓ Building, linking and syncing with Claude ...")

    {microseconds, _result} =
      :timer.tc(fn ->
        Claude.build_and_link(config)
      end)

    Mix.shell().info("✓ Done in #{microseconds / 1_000_000}s. Available at .claude/settings.json")
  end
end
