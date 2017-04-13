defmodule OnMaintenance.Mixfile do
  use Mix.Project

  def project do
    [app: :on_maintenance,
     version: "0.5.2",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     description: description(),
     package: package(),]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger, :cowboy, :plug]]
  end

  defp deps do
    [
      {:mix_test_watch, "~> 0.3", only: :dev, runtime: false},
      {:ex_unit_notifier, "~> 0.1", only: :test},
      {:cowboy, "~> 1.0"},
      {:plug, "~> 1.0"},
      {:poison, "~> 1.0"},
      {:sqlitex, "~> 1.3"},
      {:mock, "~> 0.2.0", only: :test},
      {:inch_ex, only: :docs},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp description do
    """
    Plug.OnMaintenance, an Elixir Plug, is used to disable access to your application for some length of time.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["Wilfrido T. Nuqui Jr."],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/wnuqui/on_maintenance",
        "Docs" => "http://hexdocs.pm/on_maintenance"
      }
    ]
  end
end
