defmodule Metrist.Agent.Router do
  use Commanded.Commands.Router
  alias Metrist.Agent.Command

  middleware Commanded.Middleware.Logger

  identify Metrist.Agent, by: :uuid
  dispatch Command.Create, to: Metrist.Agent
  dispatch Command.HandlePing, to: Metrist.Agent
end
