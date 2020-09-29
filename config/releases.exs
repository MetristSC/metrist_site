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

config :metrist, Metrist.Repo,
  password: mpp

config :metrist, Metrist.EventStore,
  password: mepp
