defmodule Distillery.Mixfile do
  use Mix.Project

  def project do
    [
      app: :distillery,
      version: "2.0.0",
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      aliases: aliases(),
      elixirc_paths: elixirc_paths(Mix.env),
      preferred_cli_env: [
        docs: :docs,
        "hex.publish": :docs,
        "eqc.mini": :test,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.html": :test,
        "coveralls.json": :test,
        "coveralls.post": :test,
      ],
      test_coverage: [tool: ExCoveralls],
      dialyzer: [
        flags: [:error_handling, :race_conditions, :underspecs]
      ]
    ]
  end

  def application do
    [extra_applications: [:runtime_tools, :logger]]
  end

  defp deps do
    [
      {:artificery, "~> 0.2"},
      {:ex_doc, "~> 0.13", only: [:docs]},
      {:excoveralls, "~> 0.6", only: [:test]},
      {:eqc_ex, "~> 1.4", only: [:test]},
      {:ex_unit_clustered_case, "~> 0.3", only: [:test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.2", only: [:dev], runtime: false}
    ]
  end

  defp description do
    """
    Build releases of your Mix projects with ease!
    """
  end

  defp package do
    [
      files: ["lib", "priv", "mix.exs", "README.md", "LICENSE.md"],
      maintainers: ["Paul Schoenfelder"],
      licenses: ["MIT"],
      links: %{
        Changelog: "https://github.com/bitwalker/distillery/blob/master/CHANGELOG.md",
        GitHub: "https://github.com/bitwalker/distillery"
      }
    ]
  end

  defp aliases do
    [
      docs: [&mkdocs/1, "docs"],
      c: ["compile", "format --check-equivalent"],
      "compile-check": [
        "compile", 
        "format --check-formatted --dry-run", 
        "dialyzer --halt-exit-status"
      ],
    ]
  end

  defp mkdocs(_args) do
    docs = Path.join([File.cwd!, "bin", "docs"])
    {_, 0} = System.cmd(docs, ["build"], into: IO.stream(:stdio, :line))
  end

  defp docs do
    [
      source_url: "https://github.com/bitwalker/distillery",
      homepage_url: "https://github.com/bitwalker/distillery",
      main: "home"
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
