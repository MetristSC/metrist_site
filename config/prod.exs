use Mix.Config

# This is very much non-12FA, but the quickest way from here to there.

config :metrist, MetristWeb.Endpoint,
  url: [host: "app.metri.st", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :info

config :metrist, Metrist.Repo,
  username: "metrist",
  password: "-- password set in runtime config --",
  database: "metrist_prod",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :metrist, Metrist.EventStore,
   serializer: Commanded.Serialization.JsonSerializer,
   username: "metrist",
   password: "-- password set in runtime config --",
   database: "metrist_eventstore_prod",
   hostname: "localhost",
   pool_size: 10

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
  secret_key_base: secret_key_base,
  server: true
