defmodule Metrist.User.Router do
  use Commanded.Commands.Router
  alias Metrist.User.Command

  middleware Commanded.Middleware.Logger

  identify Metrist.User, by: :uuid
  dispatch Command.Register, to: Metrist.User
end
