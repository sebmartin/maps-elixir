defmodule Maps.MixProject do
  use Mix.Project

  def project do
    [
      app: :maps,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      escript: [main_module: Maps.CLI],
      deps: deps()
    ]
  end

  defp deps do
    [
      {:math, "~> 0.7"},
      {:mox, "~> 1.0"},
      {:sleeplocks, "~> 1.1"},
      {:temp, "~> 0.4"},
      {:yaml_elixir, "~> 2.8"}
    ]
  end
end
