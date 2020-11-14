defmodule Metrist.Agent.Command.Create do
  @moduledoc """
  Register a new agent.
  """
  use TypedStruct

  @derive Jason.Encoder
  typedstruct do
    field :uuid, String.t(), enforce: true
    field :account_uuid, String.t(), enforce: true
    field :agent_id, String.t(), enforce: true
  end
end

defmodule Metrist.Agent.Command.HandlePing do
  @moduledoc """
  Handle a received ping.
  """
  use TypedStruct

  @derive Jason.Encoder
  typedstruct do
    field :uuid, String.t(), enforce: true
  end
end
