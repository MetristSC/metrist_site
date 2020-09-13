defmodule Metrist.User.Event.Registered do
  @moduledoc """
  Emitted when a user has been registered.
  """
  use TypedStruct

  @derive Jason.Encoder
  typedstruct do
    field :uuid, String.t(), enforce: true
    field :provider, String.t(), enforce: true
    field :provider_id, String.t(), enforce: true
  end
end
