defmodule Metrist.MixProject do
  use Mix.Project

  def project do
    [
      app: :metrist,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      releases: [
        metrist: [
          steps: [:assemble, :tar]]]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Metrist.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.5.4"},
      {:phoenix_ecto, "~> 4.1"},
      {:ecto_sql, "~> 3.4"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_view, "~> 0.14.2"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, "~> 0.2"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:commanded, "~> 1.2"},
      {:commanded_eventstore_adapter, "~> 1.2"},
      {:commanded_ecto_projections, "~> 1.2"},
      {:ueberauth_github, "~> 0.8.0"},
      {:typed_struct, "~> 0.2.1"},
      {:elixir_uuid, "~> 1.2"},
      {:phoenix_pubsub, "~> 2.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "event_store.setup", "cmd npm install --prefix assets"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "event_store.setup": ["event_store.create", "event_store.init"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "event_store.reset": ["event_store.drop", "event_store.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet",
             "event_store.setup", "test"]
    ]
  end
end
