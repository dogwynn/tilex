defmodule Tilex.MixProject do
  use Mix.Project

  def project do
    [
      app: :tilex,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:zstd, "~> 0.2.0"},
      {:sweet_xml, "~> 0.6.6"},
      {:csv, "~> 2.3"},
    ]
  end
end
