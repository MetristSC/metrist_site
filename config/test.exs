use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :metrist, Metrist.Repo,
  username: "postgres",
  password: "postgres",
  database: "metrist_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :metrist, Metrist.EventStore,
   serializer: Commanded.Serialization.JsonSerializer,
   username: "postgres",
   password: "postgres",
   database: "metrist_eventstore_test#{System.get_env("MIX_TEST_PARTITION")}",
   hostname: "localhost",
   pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :metrist, MetristWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
