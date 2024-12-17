defmodule Spooks.MixProject do
  use Mix.Project

  def project do
    [
      app: :spooks,
      version: "0.1.5",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "Spooks Agentic Workflow Engine",
      source_url: "https://github.com/Cobenian/spooks",
      docs: [
        main: "Spooks",
        extras: ["README.md", "CHANGELOG.md"],
        authors: ["Bryan Weber", "Bryan Tylor"]
      ]
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
      {:ecto, "~> 3.12"},
      {:jason, "~> 1.4"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  def description do
    """
    Spooks is an agentic workflow library for Elixir. It is intended to be used with Ecto and Phoenix. LLMs can be used to provide additional functionality.
    """
  end

  defp package() do
    [
      files: ~w(lib .formatter.exs mix.exs README* LICENSE* CHANGELOG*),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/Cobenian/spooks"}
    ]
  end
end
