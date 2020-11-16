defmodule Metrist.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    Metrist.InfluxStore.initialize()

    children = [
      Metrist.App,
      Metrist.Repo,
      MetristWeb.Telemetry,
      Metrist.PubSub,
      MetristWeb.Endpoint,
      Metrist.User.Projector,
      Metrist.User.RegistrationProcessManager,
      Metrist.Account.Projector.ByOwner,
      Metrist.Account.Projector.ByApiKey,
      Metrist.Agent.Projector,
      Metrist.Agent.PresenceSupervisor,
      Metrist.InfluxStore
    ]

    opts = [strategy: :one_for_one, name: Metrist.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MetristWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
