defmodule AlphaVantageApi.MixProject do
  use Mix.Project

  def project do
    [
      app: :alpha_vantage_api,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :httpoison, :timex, :con_cache],
      mod: {AlphaVantageApi.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.6"},
      {:jason, "~> 1.2"},
      {:timex, "~> 3.5"},
      {:con_cache, "~> 0.13"}
    ]
  end
end
