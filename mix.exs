defmodule Exrbbench.Mixfile do
  use Mix.Project

  def project do
    [app: :exrbbench,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application() do
    [
      applications: [:logger],
      mod: {Exrbbench, []}
    ]
  end

  defp deps do
    [
      {:benchee, "~> 0.6"},
      {:benchee_html, "~> 0.1"},
      {:export, "~> 0.1"},
    ]
  end
end
