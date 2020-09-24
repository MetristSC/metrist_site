defmodule Metrist.Node do
  @moduledoc """
  Node aggregate root.

  Nodes are the central entity that contain their own
  timeline and data. Nodes must report in regularly or
  else the aggregate will exit and the node will deregister.
  """
  use TypedStruct
  require Logger
  alias Metrist.Node.Command
  alias Metrist.Node.Event

  @derive Jason.Encoder
  typedstruct do
    field :uuid, String.t(), enforce: true
    field :account_uuid, String.t(), enforce: true
    field :node_id, String.t(), enforce: true
  end

  # Command handlers

  def execute(%__MODULE__{uuid: nil}, c = %Command.Create{}) do
    %Event.Created{uuid: c.uuid,
      account_uuid: c.account_uuid,
      node_id: c.node_id}
  end
  def execute(_node, %Command.Create{}) do
    nil
  end

  def execute(_node = %__MODULE__{}, c = %Command.HandlePing{}) do
    Logger.info("Ping command #{inspect c}, now what?")
    nil
  end

  # Event handlers

  def apply(node, e = %Event.Created{}) do
    %__MODULE__{node |
                uuid: e.uuid,
                account_uuid: e.account_uuid,
                node_id: e.node_id}
  end
end
