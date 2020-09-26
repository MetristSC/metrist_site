use Mix.Config

# This is very much non-12FA, but the quickest way from here to there.

config :metrist, MetristWeb.Endpoint,
  url: [host: "app.metri.st", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :info

config :metrist, Metrist.Repo,
  username: "metrist",
  password: System.get_env("REPO_PASSWORD"),
  database: "metrist_prod",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :metrist, Metrist.EventStore,
   serializer: Commanded.Serialization.JsonSerializer,
   username: "metrist",
   password: System.get_env("EVENT_STORE_PASSWORD"),
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
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: secret_key_base,
  server: true

# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
#     config :metrist, MetristWeb.Endpoint,
#       ...
#       url: [host: "example.com", port: 443],
#       https: [
#         port: 443,
#         cipher_suite: :strong,
#         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#         certfile: System.get_env("SOME_APP_SSL_CERT_PATH"),
#         transport_options: [socket_opts: [:inet6]]
#       ]
#
# The `cipher_suite` is set to `:strong` to support only the
# latest and more secure SSL ciphers. This means old browsers
# and clients may not be supported. You can set it to
# `:compatible` for wider support.
#
# `:keyfile` and `:certfile` expect an absolute path to the key
# and cert in disk or a relative path inside priv, for example
# "priv/ssl/server.key". For all supported SSL configuration
# options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
#
# We also recommend setting `force_ssl` in your endpoint, ensuring
# no data is ever sent via http, always redirecting to https:
#
#     config :metrist, MetristWeb.Endpoint,
#       force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.
