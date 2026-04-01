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
end
