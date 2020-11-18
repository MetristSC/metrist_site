import Config

mpp = System.get_env("METRIST_PROD_PASSWORD") ||
  raise "Environment variable METRIST_PROD_PASSWORD is missing!"

mepp = System.get_env("METRIST_EVENTSTORE_PROD_PASSWORD") ||
  raise "Environment variable METRIST_EVENTSTORE_PROD_PASSWORD is missing!"

ghid = System.get_env("GITHUB_CLIENT_ID") ||
  raise "Environment variable GITHUB_CLIENT_ID is missing!"

ghsec = System.get_env("GITHUB_CLIENT_SECRET") ||
  raise "Environment variable GITHUB_CLIENT_SECRET is missing!"

config :metrist, Metrist.Repo,
  password: mpp

config :metrist, Metrist.EventStore,
  password: mepp

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: ghid
  client_secret: ghsec
