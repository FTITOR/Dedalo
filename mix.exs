defmodule Dedalo.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :dedalo,
      version: @version,
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      test_coverage: [tool: ExCoveralls],
      description: """
      Build, link and sync LLM structure from an Elixir well-defined base.
      """,
      name: "Dedalo",
      docs: docs(),
      dialyzer: [],
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nimble_parsec, "1.3.1", only: :docs, runtime: false, override: true},
      {:jason, "~> 1.0"},
      {:yaml_elixir, "~> 2.12"},
      {:ex_doc, "0.24.0", only: :docs, runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false, optional: true},
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test"]
  defp elixirc_paths(_), do: ["lib"]

  defp docs do
    [
      main: "Mix.Tasks.Dedalo",
      source_ref: "v#{@version}",
      source_url: "https://github.com/FTITOR/Dedalo"
    ]
  end

  defp package do
    [
      name: "dedalo",
      maintainers: ["Francisco Ramirez", "Jorge Garrido"],
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/FTITOR/Dedalo"}
    ]
  end
end
