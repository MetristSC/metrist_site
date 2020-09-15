defmodule Metrist.Account.Event.Created do
  @moduledoc """
  Emitted on account creation.
  """
  use TypedStruct

  @derive Jason.Encoder
  typedstruct do
    field :uuid, String.t(), enforce: true
    field :name, String.t(), enforce: true
    field :owner, String.t(), enforce: true
    field :api_key, String.t(), enforce: true
  end
end
