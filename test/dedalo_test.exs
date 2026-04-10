defmodule DedaloTest do
  @moduledoc false
  use ExUnit.Case, async: true

  test "LLM not found" do
    Mix.shell(Mix.Shell.Process)

    Mix.Tasks.Dedalo.run(["cursor", "--path", ".agents/conf.yml"])

    assert_received {:mix_shell, :error, ["⚠️  no supported LLM, please execute mix help dedalo for more info."]}
  end

  test "YML not found" do
    Mix.shell(Mix.Shell.Process)

    Mix.Tasks.Dedalo.run(["claude", "--path", ".agents/conf0.yml"])

    assert_received {:mix_shell, :error, ["⚠️  missing conf file, please ensure file exists on the provided path."]}
  end

  test "Claude success" do
    Mix.shell(Mix.Shell.Process)

    Mix.Tasks.Dedalo.run(["claude", "--path", ".agents/conf.yml"])

    assert_received {:mix_shell, :info, ["📖 conf file found, processing ..."]}
    assert_received {:mix_shell, :info, ["✓ Building, linking and syncing with Claude ..."]}
    assert_received {:mix_shell, :info, [output]}
    assert output =~ "Available at .claude/settings.json"
  end

  test "Claude generates CLAUDE.md with command agents in Available Agents" do
    Mix.shell(Mix.Shell.Process)

    Mix.Tasks.Dedalo.run(["claude", "--path", ".agents/conf.yml"])

    content = File.read!("CLAUDE.md")

    assert content =~ "## Available Agents"
    assert content =~ "`/my_command_agent`"
    assert content =~ "`/my_other_command_agent`"
    assert content =~ "Workflow: `.agents/workflows/my_command_agent.md`"
  end

  test "Claude generates CLAUDE.md with hook agents in Automated Agents" do
    Mix.shell(Mix.Shell.Process)

    Mix.Tasks.Dedalo.run(["claude", "--path", ".agents/conf.yml"])

    content = File.read!("CLAUDE.md")

    assert content =~ "## Automated Agents"
    assert content =~ "`my_hook_agent`"
    assert content =~ "`post-commit`"
    assert content =~ "Workflow: `.agents/workflows/my_hook_agent.md`"
  end

  test "Claude generates CLAUDE.md with workflows" do
    Mix.shell(Mix.Shell.Process)

    Mix.Tasks.Dedalo.run(["claude", "--path", ".agents/conf.yml"])

    content = File.read!("CLAUDE.md")

    assert content =~ "## Available Workflows"
    assert content =~ "`my_command_agent`"
    assert content =~ "`my_other_command_agent`"
    assert content =~ "`my_hook_agent`"
    assert content =~ "Path: `.agents/workflows/my_command_agent.md`"
  end

  test "Claude generates CLAUDE.md with conventions" do
    Mix.shell(Mix.Shell.Process)

    Mix.Tasks.Dedalo.run(["claude", "--path", ".agents/conf.yml"])

    content = File.read!("CLAUDE.md")

    assert content =~ "## Global Conventions"
    assert content =~ "**Language:**"
    assert content =~ "**Formatting:**"
    assert content =~ "`mix format`"
  end

  test "Gemini success" do
    Mix.shell(Mix.Shell.Process)

    Mix.Tasks.Dedalo.run(["gemini", "--path", ".agents/conf.yml"])

    assert_received {:mix_shell, :info, ["📖 conf file found, processing ..."]}
    assert_received {:mix_shell, :info, ["✓ Building, linking and syncing with Gemini ..."]}
    assert_received {:mix_shell, :info, [output]}
    assert output =~ "Available at .gemini/"
  end

  test "Escript" do
    Mix.shell(Mix.Shell.Process)

    Dedalo.CLI.main(["cursor", "--path", ".agents/conf.yml"])

    assert_received {:mix_shell, :error, ["⚠️  no supported LLM, please execute mix help dedalo for more info."]}
  end

  test "Gemini generates GEMINI.md with command agents in Available Agents" do
    Mix.shell(Mix.Shell.Process)

    Mix.Tasks.Dedalo.run(["gemini", "--path", ".agents/conf.yml"])

    content = File.read!(".gemini/GEMINI.md")

    assert content =~ "## Available Agents"
    assert content =~ "`/my_command_agent`"
    assert content =~ "`/my_other_command_agent`"
    assert content =~ "Workflow: `.agents/workflows/my_command_agent.md`"
  end

  test "Gemini generates GEMINI.md with hook agents in Automated Agents" do
    Mix.shell(Mix.Shell.Process)

    Mix.Tasks.Dedalo.run(["gemini", "--path", ".agents/conf.yml"])

    content = File.read!(".gemini/GEMINI.md")

    assert content =~ "## Automated Agents"
    assert content =~ "`my_hook_agent`"
    assert content =~ "`post-commit`"
    assert content =~ "Workflow: `.agents/workflows/my_hook_agent.md`"
  end

  test "Gemini generates GEMINI.md with workflows" do
    Mix.shell(Mix.Shell.Process)

    Mix.Tasks.Dedalo.run(["gemini", "--path", ".agents/conf.yml"])

    content = File.read!(".gemini/GEMINI.md")

    assert content =~ "## Available Workflows"
    assert content =~ "`my_command_agent`"
    assert content =~ "`my_other_command_agent`"
    assert content =~ "`my_hook_agent`"
    assert content =~ "Path: `.agents/workflows/my_command_agent.md`"
  end

  test "Gemini generates GEMINI.md with conventions" do
    Mix.shell(Mix.Shell.Process)

    Mix.Tasks.Dedalo.run(["gemini", "--path", ".agents/conf.yml"])

    content = File.read!(".gemini/GEMINI.md")

    assert content =~ "## Global Conventions"
    assert content =~ "**Language:**"
    assert content =~ "**Formatting:**"
    assert content =~ "`mix format`"
  end
end
