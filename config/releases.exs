import Config

mpp =
  System.get_env("METRIST_PROD_PASSWORD") ||
    raise """
    Environment variable METRIST_PROD_PASSWORD is missing!
    """

mepp =
  System.get_env("METRIST_EVENTSTORE_PROD_PASSWORD") ||
    raise """
    Environment variable METRIST_EVENTSTORE_PROD_PASSWORD is missing!
    """

secret_key_base =
  System.get_env("PHOENIX_SECRET_KEY_BASE") ||
    raise """
    environment variable PHOENIX_SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :metrist, Metrist.Repo,
  password: mpp

config :metrist, Metrist.EventStore,
  password: mepp

config :metrist, MetristWeb.Endpoint,
  secret_key_base: secret_key_base
