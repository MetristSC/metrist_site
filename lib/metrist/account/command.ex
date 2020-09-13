defmodule Metrist.Account.Command.Create do
  @moduledoc """
  Create a new account with the user as the
  owner.
  """
  use TypedStruct

  @derive Jason.Encoder
  typedstruct do
    field :uuid, String.t(), enforce: true
    field :name, String.t(), enforce: true
    field :owner, String.t(), enforce: true
  end
end
