defmodule Metrist.User do
  @moduledoc """
  User aggregate
  """
  use TypedStruct
  require Logger
  alias Metrist.User.Command
  alias Metrist.User.Event

  @derive Jason.Encoder
  typedstruct do
    field :uuid, String.t(), enforce: true
    field :provider, String.t(), enforce: true
    field :provider_id, String.t(), enforce: true
  end

  # Command handlers

  def execute(%__MODULE__{uuid: nil}, c = %Command.Register{}) do
    %Event.Registered{uuid: c.uuid, provider: c.provider, provider_id: c.provider_id}
  end

  def execute(_user, %Command.Register{}) do
    # Duplicate registration somehow, we don't care
    nil
  end

  # Event handlers

  def apply(user, e = %Event.Registered{}) do
    %__MODULE__{user |
                uuid: e.uuid,
                provider: e.provider,
                provider_id: e.provider_id}
  end
end
