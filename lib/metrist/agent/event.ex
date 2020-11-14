defmodule Metrist.Agent.Event.Created do
  @moduledoc """
  Emitted when a agent newly appears.
  """
  use TypedStruct

  @derive Jason.Encoder
  typedstruct do
    field :uuid, String.t(), enforce: true
    field :account_uuid, String.t(), enforce: true
    field :agent_id, String.t(), enforce: true
  end
end

defmodule Metrist.Agent.Event.PingReceived do
  @moduledoc """
  Emitted when a agent sends a ping.
  """
  use TypedStruct

  @derive Jason.Encoder
  typedstruct do
    field :uuid, String.t(), enforce: true
    field :time_us, integer, enfore: true
  end
end
