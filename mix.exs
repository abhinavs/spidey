defmodule Spidey.MixProject do
  use Mix.Project

  @name "Spidey"
  @version "0.3.2"
  @repo_url "https://github.com/manzanit0/spidey"

  def project do
    [
      app: :spidey,
      name: @name,
      source_url: @repo_url,
      description:
        "A dead-simple, concurrent web crawler which focuses on ease of use and speed.",
      package: package(),
      docs: docs(),
      version: @version,
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      test_coverage: [tool: ExCoveralls],
      escript: [main_module: Spidey.CLI]
    ]
  end

  def application do
    [
      mod: {Spidey.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 2.0"},
      {:floki, "~> 0.34.0"},
      {:excoveralls, "~> 0.16.0", only: :test},
      {:mox, "~> 1.0", only: :test},
      {:ex_doc, ">= 0.29.0", only: :dev, runtime: false}
    ]
  end

  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["lib"]

  def docs do
    [
      source_ref: "v#{@version}",
      source_url: @repo_url,
      main: @name
    ]
  end

  def package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @repo_url}
    ]
  end
end
