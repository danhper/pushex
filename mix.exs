defmodule Pushex.Mixfile do
  use Mix.Project

  def project do
    [app: :pushex,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :httpoison],
     mod: {Pushex, []}]
  end

  defp deps do
    [{:httpoison, "~> 0.8"},
     {:poison,    "~> 2.1"},
     {:vex,       github: "tuvistavie/vex", branch: "add-type-validator"}]
  end
end
