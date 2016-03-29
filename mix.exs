defmodule Pushex.Mixfile do
  use Mix.Project

  @version "0.0.1"

  def project do
    [app: :pushex,
     version: @version,
     elixir: "~> 1.2",
     source_ur: "https://github.com/tuvistavie/pushex",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package,
     deps: deps,
     docs: [source_ref: "#{@version}", extras: ["README.md"], main: "readme"]]
  end

  def application do
    [applications: [:logger, :httpoison],
     mod: {Pushex, []},
     description: 'Mobile push notification library']
  end

  defp deps do
    [{:httpoison, "~> 0.8"},
     {:poison,    "~> 2.1"},
     {:vex,       github: "tuvistavie/vex", branch: "add-type-validator"},
     {:earmark,   "~> 0.1", only: :dev},
     {:ex_doc,    "~> 0.11", only: :dev}]
  end

  defp package do
    [
      maintainers: ["Daniel Perez"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/tuvistavie/pushex",
        "Docs" => "http://hexdocs.pm/pushex/"
      }
    ]
  end
end
