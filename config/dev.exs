use Mix.Config

# Configure your database
config :metrist_site, MetristSite.Repo,
  username: "postgres",
  password: "postgres",
  database: "metrist_site_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :metrist_site, MetristSite.EventStore,
   serializer: Commanded.Serialization.JsonSerializer,
   username: "postgres",
   password: "postgres",
   database: "metrist_site_eventstore_dev",
   hostname: "localhost",
   pool_size: 10

config :metrist_site, MetristSiteWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

config :metrist_site, MetristSiteWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/metrist_site_web/(live|views)/.*(ex)$",
      ~r"lib/metrist_site_web/templates/.*(eex)$"
    ]
  ]

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime
