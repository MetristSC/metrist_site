defmodule Metrist.Account.Router do
  use Commanded.Commands.Router
  alias Metrist.Account.Command

  middleware Commanded.Middleware.Logger

  identify Metrist.Account, by: :uuid
  dispatch Command.Create, to: Metrist.Account
end
