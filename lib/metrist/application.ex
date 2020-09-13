defmodule Metrist.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  use Commanded.Application,
     otp_app: :metrist,
     event_store: [
       adapter: Commanded.EventStore.Adapters.EventStore,
       event_store: Metrist.EventStore
     ]

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Metrist.Repo,
      # Start the Telemetry supervisor
      MetristWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Metrist.PubSub},
      # Start the Endpoint (http/https)
      MetristWeb.Endpoint
      # Start a worker by calling: Metrist.Worker.start_link(arg)
      # {Metrist.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
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
