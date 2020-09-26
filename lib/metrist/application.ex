defmodule Metrist.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Metrist.App,
      Metrist.Repo,
      MetristWeb.Telemetry,
      {Phoenix.PubSub, name: Metrist.PubSub},
      MetristWeb.Endpoint,
      Metrist.User.Projector,
      Metrist.User.RegistrationProcessManager,
      Metrist.Account.Projector.ByOwner,
      Metrist.Account.Projector.ByApiKey,
      Metrist.Node.Projector,
      Metrist.Node.PresenceSupervisor,
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
