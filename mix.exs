defmodule Summerizer.MixProject do
  use Mix.Project

  def project do
    [
      app: :summerizer,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Summerizer.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:styler, "~> 1.1", only: [:dev, :test], runtime: false}
    ]
  end
end
