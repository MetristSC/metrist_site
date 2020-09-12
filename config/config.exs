# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :metrist_site,
  ecto_repos: [MetristSite.Repo],
  generators: [binary_id: true],
  event_stores: [MetristSite.EventStore]

# Configures the endpoint
config :metrist_site, MetristSiteWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "UFqDE7PnGq+OOMmMj94I9KiS3gN5BcKVhv+0SAZH9ayGD5RZYPoq+VEJmaquMHdk",
  render_errors: [view: MetristSiteWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: MetristSite.PubSub,
  live_view: [signing_salt: "vrU39nPD"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
