defmodule Metrist.Node.Command.Create do
  @moduledoc """
  Register a new node.
  """
  use TypedStruct

  @derive Jason.Encoder
  typedstruct do
    field :uuid, String.t(), enforce: true
    field :account_uuid, String.t(), enforce: true
    field :node_id, String.t(), enforce: true
  end
end

defmodule Metrist.Node.Command.HandlePing do
  @moduledoc """
  Handle a received ping.
  """
  use TypedStruct

  @derive Jason.Encoder
  typedstruct do
    field :uuid, String.t(), enforce: true
  end
end
