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
      {:mox, "~> 1.0"},
      {:yaml_elixir, "~> 2.8"}
    ]
  end
end
