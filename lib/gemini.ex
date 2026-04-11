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
  * agents
  * conventions
  * workflows
  ```
  """
  def build_and_link(opts) do
    :ok = File.mkdir_p!(@base_dir)

    deny_conf = Keyword.get(opts, :deny, %{})
    allow_conf = Keyword.get(opts, :allow, %{})
    agents = Keyword.get(opts, :agents, [])
    conventions = Keyword.get(opts, :conventions, %{})
    workflows = Keyword.get(opts, :workflows, [])

    :ok = md(deny_conf, allow_conf, conventions, agents, workflows)

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

  defp md(deny, allow, conventions, agents, workflows) do
    conf_md =
      :dedalo
      |> :code.priv_dir()
      |> Path.join(@gemini_md)
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

    @base_dir
    |> Kernel.<>("/")
    |> Kernel.<>(@md_file)
    |> File.write(conf_md)
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
