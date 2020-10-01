use Mix.Config

config :metrist, Metrist.Repo,
  username: "metrist_prod",
  password: "see runtime config",
  database: "metrist_prod",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: false,
  pool_size: 10

config :metrist, Metrist.EventStore,
   serializer: Commanded.Serialization.JsonSerializer,
   username: "metrist_eventstore_prod",
   password: "see runtime config",
   database: "metrist_eventstore_prod",
   hostname: "localhost",
   pool_size: 10

config :metrist, Metrist.InfluxStore,
  database: "metrist_prod"

# We have the shared secret key base in Github so all the builds
# have the same one, independent of node, too. So we burn it into
# the release at compile time.
secret_key_base =
  System.get_env("PHOENIX_SECRET_KEY_BASE") ||
    raise """
    environment variable PHOENIX_SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :metrist, MetristWeb.Endpoint,
  http: [
    port: 4000,
    transport_options: [socket_opts: [:inet6]]
  ],
  url: [
    host: "app.metri.st",
    port: 80
  ],
  cache_static_manifest: "priv/static/cache_manifest.json",
  secret_key_base: secret_key_base,
  server: true

config :logger, level: :info
