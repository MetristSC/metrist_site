defmodule Metrist.User.Command.Register do
  @moduledoc """
  Register a new user. Create a default account
  for the user.
  """
  use TypedStruct

  typedstruct do
    field :uuid, String.t(), enforce: true
    field :provider, String.t(), enforce: true
    field :provider_id, String.t(), enforce: true
  end
end
