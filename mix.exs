defmodule Pushex.Mixfile do
  use Mix.Project

  @version "0.0.5"

  def project do
    [app: :pushex,
     version: @version,
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     description: "Mobile push notification library",
     source_url: "https://github.com/tuvistavie/pushex",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package,
     deps: deps,
     test_coverage: [tool: ExCoveralls],
     dialyzer: [plt_add_apps: [:poison, :httpoison, :vex]],
     docs: [source_ref: "#{@version}", extras: ["README.md"], main: "readme"]]
  end

  def application do
    [applications: [:logger, :httpoison, :vex, :poolboy],
     mod: {Pushex.App, []},
     description: 'Mobile push notification library']
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [{:httpoison, "~> 0.8"},
     {:poison,    "~> 1.5 or ~> 2.1"},
     {:poolboy,   "~> 1.5"},
     {:vex,       "~> 0.5"},
     {:apns,      github: "tuvistavie/apns4ex", branch: "dev"},
     {:excoveralls, "~> 0.5", only: :test},
     {:dialyxir, "~> 0.3", only: :dev},
     {:earmark,   "~> 0.1", only: :dev},
     {:ex_doc,    "~> 0.11", only: :dev}]
  end

  defp package do
    [
      maintainers: ["Daniel Perez"],
      files: ["lib", "mix.exs", "README.md"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/tuvistavie/pushex",
        "Docs" => "http://hexdocs.pm/pushex/"
      }
    ]
  end
end
