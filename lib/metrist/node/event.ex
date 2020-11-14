defmodule Metrist.Node.Event.Created do
  @moduledoc """
  Emitted when a node newly appears.
  """
  use TypedStruct

  @derive Jason.Encoder
  typedstruct do
    field :uuid, String.t(), enforce: true
    field :account_uuid, String.t(), enforce: true
    field :node_id, String.t(), enforce: true
  end
end

defmodule Metrist.Node.Event.PingReceived do
  @moduledoc """
  Emitted when a node sends a ping.
  """
  use TypedStruct

  @derive Jason.Encoder
  typedstruct do
    field :uuid, String.t(), enforce: true
    field :time_us, integer, enfore: true
  end
end
