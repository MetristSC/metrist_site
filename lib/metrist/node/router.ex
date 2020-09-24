defmodule Metrist.Node.Router do
  use Commanded.Commands.Router
  alias Metrist.Node.Command

  middleware Commanded.Middleware.Logger

  identify Metrist.Node, by: :uuid
  dispatch Command.Create, to: Metrist.Node
  dispatch Command.HandlePing, to: Metrist.Node
end
