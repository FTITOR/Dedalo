defmodule Dedalo.Claude do
  @moduledoc """
  Claude builder and linker for `dedalo` mix tool.
  """
  @header "AUTO-GENERATED — Do not edit manually. Edit your yml file instead and run again mix dedalo tool."
  @base_dir ".claude"
  @settings_file "settings.json"
  @claude_md "CLAUDE.md"
  @claude_md_template "claude.md"

  @doc """
  With options provided build a Claude env, supported options are:

  ```
  * deny
  * allow
  * agents
  * conventions
  * workflows
  ```
  """
  def build_and_link(opts) do
    :ok = Enum.each([:rm_rf!, :mkdir_p!], &apply(File, &1, [@base_dir]))

    deny_conf = Keyword.get(opts, :deny, %{})
    allow_conf = Keyword.get(opts, :allow, %{})
    agents = Keyword.get(opts, :agents, [])
    conventions = Keyword.get(opts, :conventions, %{})
    workflows = Keyword.get(opts, :workflows, [])

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

    :ok = md(deny_conf, allow_conf, conventions, agents, workflows)
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

  defp md(deny, allow, conventions, agents, workflows) do
    conf_md =
      :dedalo
      |> :code.priv_dir()
      |> Path.join(@claude_md_template)
      |> File.read!()
      |> EEx.eval_string(
        header: @header,
        denied_files: render_entries(Map.get(deny, "files", []), "path", "reason"),
        denied_commands: render_entries(Map.get(deny, "commands", []), "pattern", "reason"),
        allowed_commands: render_entries(Map.get(allow, "commands", []), "pattern", "description"),
        conventions: render_conventions(conventions),
        available_agents: render_command_agents(agents),
        automated_agents: render_hook_agents(agents),
        workflows: render_workflows(workflows)
      )
      |> String.trim()
      |> Kernel.<>("\n")

    File.write(@claude_md, conf_md)
  end

  defp render_entries(entries, key1, key2) do
    entries
    |> Enum.map(fn entry ->
      "- `#{Map.get(entry, key1, "")}` - #{Map.get(entry, key2, "")}"
    end)
    |> Enum.join("\n")
  end

  defp render_conventions(conventions) do
    language_rule = conventions |> Map.get("language_rule", "") |> String.trim()

    formatting =
      conventions
      |> Map.get("formatting", [])
      |> Enum.map(fn f ->
        required = if Map.get(f, "required", false), do: " (required)", else: ""
        "- `#{Map.get(f, "command", "")}` — #{Map.get(f, "description", "")}#{required}"
      end)
      |> Enum.join("\n")

    """
    **Language:** #{language_rule}

    **Formatting:**
    #{formatting}
    """
    |> String.trim()
  end

  defp render_command_agents(agents) do
    agents
    |> Enum.filter(&(Map.get(&1, "trigger") == "command"))
    |> Enum.map(fn agent ->
      command = Map.get(agent, "command", "")
      description = Map.get(agent, "description", "")
      workflow = Map.get(agent, "workflow", "")
      "- `#{command}` — #{description}\n  Workflow: `.agents/#{workflow}`"
    end)
    |> Enum.join("\n\n")
  end

  defp render_hook_agents(agents) do
    agents
    |> Enum.filter(&(Map.get(&1, "trigger") == "hook"))
    |> Enum.map(fn agent ->
      id = Map.get(agent, "id", "")
      hook = Map.get(agent, "hook", "")
      description = Map.get(agent, "description", "")
      workflow = Map.get(agent, "workflow", "")
      "- `#{id}` — Triggered on `#{hook}`. #{description}\n  Workflow: `.agents/#{workflow}`"
    end)
    |> Enum.join("\n\n")
  end

  defp render_workflows(workflows) do
    workflows
    |> Enum.map(fn wf ->
      id = Map.get(wf, "id", "")
      description = Map.get(wf, "description", "")
      path = Map.get(wf, "path", "")
      "- `#{id}` — #{description}\n  Path: `.agents/#{path}`"
    end)
    |> Enum.join("\n\n")
  end
end
