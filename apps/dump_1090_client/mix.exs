defmodule Dump1090Client.MixProject do
  use Mix.Project

  def project do
    [
      app: :dump_1090_client,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Dump1090Client.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:aircraft, in_umbrella: true},
      {:aircraft_hanger, in_umbrella: true},
      {:pubsub, "~> 1.0"}
    ]
  end
end
