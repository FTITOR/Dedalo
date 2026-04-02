defmodule Dedalo.Claude do
  @moduledoc """
  Claude builder and linker for `dedalo` mix tool.
  """
  @header "AUTO-GENERATED — Do not edit manually. Edit your yml file instead and run again mix dedalo tool."
  @base_dir ".claude"
  @settings_file "settings.json"

  @doc """
  With options provided build a Claude env, supported options are:

  ```
  * deny
  * allow
  ```
  """
  def build_and_link(opts) do
    :ok = Enum.each([:rm_rf!, :mkdir_p!], &apply(File, &1, [@base_dir]))

    deny_conf = Keyword.get(opts, :deny, %{})
    allow_conf = Keyword.get(opts, :allow, %{})

    deny_rules = file_rules(deny_conf) ++ command_rules(deny_conf)
    allow_rules = command_rules(allow_conf)

    permissions =
      Map.new()
      |> Map.put("deny", deny_rules)
      |> Map.put("allow", allow_rules)

    conf_json =
      Map.new()
      |> Map.put("_comment", @header)
      |> Map.put("permissions", permissions)
      |> Jason.encode!(pretty: true)
      |> Kernel.<>("\n")

    @base_dir
    |> Kernel.<>("/")
    |> Kernel.<>(@settings_file)
    |> File.write(conf_json)
  end

  defp file_rules(conf) do
    conf
    |> Map.get("files", [])
    |> Enum.map(&Map.get(&1, "path", ""))
    |> Enum.map(fn path ->
      ["Read(#{path})", "Write(#{path})", "Bash(#{path})"]
    end)
    |> List.flatten()
  end

  defp command_rules(conf) do
    conf
    |> Map.get("commands", [])
    |> Enum.map(fn entry ->
      "Bash(#{Map.get(entry, "pattern", "")})"
    end)
  end
end
