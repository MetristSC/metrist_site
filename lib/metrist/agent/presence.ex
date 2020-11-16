defmodule Metrist.Agent.Presence do
  @moduledoc """
  Presence functionality for agents.

  As long as agents keep pinging, they're alive. When
  they miss 10 pings, they're dormant. When they're dormant
  for a day, they're inactive.

  This code handles these state transitions and allows other
  code to subscribe to such state transitions.

  TODO: on restart, schedule timers to state transition
  all agents that are alive/dormant in the database in case
  they don't show up.
  """
  use GenServer, restart: :transient
  require Logger
  alias Metrist.Agent.Command

if Mix.env == :dev do
  @alive_timeout 30_000
  @dormant_timeout 60_000
else
  @alive_timeout 60_000
  @dormant_timeout 86_400_000
end

  defmodule State do
    defstruct [:account_uuid, :agent_id, :agent_uuid, :state, :timer_ref]
  end

  def start_link([account_uuid, agent_id, name]) do
    GenServer.start_link(__MODULE__, [account_uuid, agent_id], name: name)
  end

  @doc """
  Register a received ping. Starts a server if needed.
  """
  def ping_received(account_uuid, agent_id) do
    # TODO not sure this is the perfect spot...
    if not exists?(account_uuid, agent_id) do
      c = %Command.Create{
        uuid: Id.generate(),
        account_uuid: account_uuid,
        agent_id: agent_id}
      Metrist.App.dispatch(c)
    end

    server = Metrist.Agent.PresenceSupervisor.find_or_start_child(account_uuid, agent_id)
    result = GenServer.cast(server, :ping_received)
    result
  end

  @doc """
  Subscribe to all _agent_ presence messages for the given account.
  """
  def subscribe(account_uuid) do
    Metrist.PubSub.subscribe("agents", account_uuid)
  end

  @doc """
  Return true if we consider the agent to be alive
  """
  def alive?(account_uuid, agent_id) do
    case Metrist.Agent.PresenceSupervisor.find_child(account_uuid, agent_id) do
      nil -> false
      pid -> GenServer.call(pid, :alive?)
    end
  end

  # Server side

  @impl true
  def init([account_uuid, agent_id]) do
    state = %State{account_uuid: account_uuid,
                   agent_id: agent_id,
                   state: :new}
    broadcast_state_change(state, :alive)
    state = schedule_timeout(state, :alive)
    {:ok, state}
  end

  @impl true
  def handle_call(:alive?, _from, state) do
    {:reply, state.state == :alive, state}
  end

  @impl true
  def handle_cast(:ping_received, state) do
    if state.state != :alive do
      broadcast_state_change(state, :alive)
    end
    dispatch_handle_ping_command(state)
    state = schedule_timeout(state, :alive)
    {:noreply, state}
  end

  @impl true
  def handle_info(:timeout, state = %State{state: :alive}) do
    Logger.debug("Timeout received in alive state")
    broadcast_state_change(state, :dormant)
    state = schedule_timeout(state, :dormant)
    {:noreply, state, :hibernate}
  end
  def handle_info(:timeout, state = %State{state: :dormant}) do
    Logger.debug("Timeout received in dormant state")
    broadcast_state_change(state, :inactive)
    {:stop, :normal, %State{state | state: :inactive}}
  end

  defp schedule_timeout(state, new_state) do
    unless is_nil(state.timer_ref) do
      Process.cancel_timer(state.timer_ref)
    end
    ref = Process.send_after(self(), :timeout, timeout_for(new_state))
    %State{state | state: new_state, timer_ref: ref}
  end

  defp broadcast_state_change(state, new_state) do
    message = {:agent_state_change, %{account_uuid: state.account_uuid,
                              agent_id: state.agent_id,
                              to_state: new_state}}
    Metrist.PubSub.broadcast("agents", state.account_uuid, message)
  end

  defp timeout_for(:alive), do: @alive_timeout
  defp timeout_for(:dormant), do: @dormant_timeout

  defp exists?(account_uuid, agent_id) do
    Metrist.Agent.Projection.by_account_and_agent_id(account_uuid, agent_id)
    |> Metrist.Repo.exists?()
  end

  defp dispatch_handle_ping_command(state) do
    agent = Metrist.Agent.Projection.by_account_and_agent_id(state.account_uuid, state.agent_id)
    |> Metrist.Repo.one()
    if agent do
      c = %Command.HandlePing{uuid: agent.uuid}
      Metrist.App.dispatch(c)
    else
      # and if not? We'll wait until registration is complete and do it the next round.
      Logger.debug("Agent not registered yet, skipping ping command")
    end
  end
end
