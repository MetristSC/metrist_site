defmodule Metrist.Agent do
  @moduledoc """
  Agent aggregate root.

  Agents are the central entity that contain their own
  timeline and data. Agents must report in regularly or
  else the aggregate will exit and the agent will deregister.
  """
  use TypedStruct
  require Logger
  alias Metrist.Agent.Command
  alias Metrist.Agent.Event

  @derive Jason.Encoder
  typedstruct do
    field :uuid, String.t(), enforce: true
    field :account_uuid, String.t(), enforce: true
    field :agent_id, String.t(), enforce: true
    field :last_ping_us, integer()
  end

  # Command handlers

  def execute(%__MODULE__{uuid: nil}, c = %Command.Create{}) do
    %Event.Created{uuid: c.uuid,
      account_uuid: c.account_uuid,
      agent_id: c.agent_id}
  end
  def execute(_agent, %Command.Create{}) do
    nil
  end

  def execute(agent = %__MODULE__{}, c = %Command.HandlePing{}) do
    %Event.PingReceived{uuid: agent.uuid,
                        time_us: :erlang.system_time(:microsecond)}
  end

  # Event handlers

  def apply(agent, e = %Event.Created{}) do
    %__MODULE__{agent |
                uuid: e.uuid,
                account_uuid: e.account_uuid,
                agent_id: e.agent_id}
  end

  def apply(agent, e = %Event.PingReceived{}) do
    %__MODULE__{agent |
                last_ping_us: e.time_us}
  end
end
