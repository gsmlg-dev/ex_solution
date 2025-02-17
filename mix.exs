defmodule GSMLG.Solution.MixProject do
  use Mix.Project

  @source_url "https://github.com/gsmlg-dev/ex_solution.git"
  @version "0.1.0"

  def project do
    [
      app: :gsmlg_solution,
      version: @version,
      elixir: "~> 1.14.1 or ~> 1.15",
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      description: "The solution for GSMLG",
      deps: deps(),
      package: package(),
      docs: docs(),
      source_url: @source_url
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md"],
      source_url: @source_url,
      source_ref: "v#{@version}"
    ]
  end

  defp package do
    [
      maintainers: ["Jonathan Gao"],
      licenses: ["MIT"],
      files: ~w(lib LICENSE mix.exs README.md),
      links: %{"GitHub" => @source_url}
    ]
  end
end
