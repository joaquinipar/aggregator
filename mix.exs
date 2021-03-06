defmodule Aggregator.MixProject do
  use Mix.Project

  def project do
    [
      app: :aggregator,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :plug_cowboy],
      env: [api_url: "https://hacker-news.firebaseio.com/v0/"],
      mod: {Aggregator.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:poison, "~> 5.0"},
      {:httpoison, "~> 1.8"},
      {:plug_cowboy, "~> 2.0"},
      {:hal, "~> 1.0.0"},
      {:scrivener_list, "~> 2.0"},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false}
    ]
  end
end
