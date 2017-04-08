defmodule MsLuis.Mixfile do
  use Mix.Project

  def project do
    [app: :ms_luis,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:ivar, "~> 0.3.0"},
      {:poison, "~> 3.0"},

      # dev deps
      {:ex_doc, "~> 0.15.0", only: :dev},
      {:credo, "~> 0.7.2", only: [:dev, :test]},
      {:bypass, "~> 0.6.0", only: :test}
    ]
  end
end
