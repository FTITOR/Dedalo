defmodule Dedalo.Gemini do
  @moduledoc """
  Gemini builder and linker for `dedalo` mix tool.
  """
  require EEx

  @base_dir ".gemini"
  @schema "https://raw.githubusercontent.com/google-gemini/gemini-cli/main/schemas/settings.schema.json"
  @settings_file "settings.json"
  @header "AUTO-GENERATED — Do not edit manually. Edit your yml file instead and run again mix dedalo tool."
  @gemini_md "gemini.md"
  @md_file "GEMINI.md"

  @doc """
  With options provided build a Gemini env, supported options are:

  ```
  * deny
  * allow
  ```
  """
  def build_and_link(opts) do
    :ok = Enum.each([:rm_rf!, :mkdir_p!], &apply(File, &1, [@base_dir]))

    deny_conf = Keyword.get(opts, :deny, %{})
    allow_conf = Keyword.get(opts, :allow, %{})

    :ok = md(deny_conf, allow_conf)

    conf_json =
      Map.new()
      |> Map.put("$schema", @schema)
      |> Jason.encode!(pretty: true)
      |> Kernel.<>("\n")

    @base_dir
    |> Kernel.<>("/")
    |> Kernel.<>(@settings_file)
    |> File.write(conf_json)
  end

  defp md(deny, allow) do
    denied_files = Map.get(deny, "files", [])
    denied_commands = Map.get(deny, "commands", [])
    allowed_commands = Map.get(allow, "commands", [])

    conf_md =
      :dedalo
      |> :code.priv_dir()
      |> Path.join(@gemini_md)
      |> File.read!()
      |> EEx.eval_string(
        header: @header,
        files: rules(denied_files, ["path", "reason"]),
        d_commands: rules(denied_commands, ["pattern", "reason"]),
        a_commands: rules(allowed_commands, ["pattern", "description"])
      )
      |> String.trim()
      |> Kernel.<>("\n")

    @base_dir
    |> Kernel.<>("/")
    |> Kernel.<>(@md_file)
    |> File.write(conf_md)
  end

  defp rules(entries, tags) do
    entries
    |> Enum.map(fn entry ->
      Enum.map(tags, &Map.get(entry, &1, ""))
    end)
    |> Enum.map(fn [entry, reason] ->
      "- `#{entry}` - #{reason}"
    end)
    |> Enum.join("\n")
  end
end
