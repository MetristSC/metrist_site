defmodule Metrist.Node.Presence do
  @moduledoc """
  Presence functionality for nodes.

  As long as nodes keep pinging, they're alive. When
  they miss 10 pings, they're dormant. When they're dormant
  for a day, they're inactive.

  This code handles these state transitions and allows other
  code to subscribe to such state transitions.

  TODO: on restart, schedule timers to state transition
  all nodes that are alive/dormant in the database in case
  they don't show up.
  """
  use GenServer
  require Logger

if Mix.env == :dev do
  @alive_timeout 30_000
  @dormant_timeout 60_000
else
  @alive_timeout 60_000
  @dormant_timeout 86_400_000
end

  defmodule State do
    defstruct [:account_uuid, :node_id, :state, :timer_ref]
  end


  def start_link([account_uuid, node_id, name]) do
    GenServer.start_link(__MODULE__, [account_uuid, node_id], name: name)
  end

  @doc """
  Register a received ping. Starts a server if needed.
  """
  def ping_received(account_uuid, node_id) do
    server = Metrist.Node.PresenceSupervisor.find_or_start_child(account_uuid, node_id)
    GenServer.cast(server, :ping_received)
  end

  @doc """
  Subscribe to all presence messages for the given account.
  """
  def subscribe(account_uuid) do
    Phoenix.PubSub.subscribe(Metrist.PubSub, topic_for(account_uuid))
  end

  # Server side

  @impl true
  def init([account_uuid, node_id]) do
    state = %State{account_uuid: account_uuid,
                   node_id: node_id,
                   state: :new}
    broadcast_state_change(state, :alive)
    state = schedule_timeout(state, :alive)
    {:ok, state}
  end

  @impl true
  def handle_cast(:ping_received, state) do
    if state.state != :alive do
      broadcast_state_change(state, :alive)
    end
    state = schedule_timeout(state, :alive)
    {:noreply, state}
  end

  @impl true
  def handle_info(:timeout, state = %State{state: :alive}) do
    broadcast_state_change(state, :dormant)
    state = schedule_timeout(state, :dormant)
    {:noreply, state, :hibernate}
  end
  def handle_info(:timeout, state = %State{state: :dormant}) do
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
    topic = topic_for(state.account_uuid)
    message = {:node_state_change, %{account_uuid: state.account_uuid,
                              node_id: state.node_id,
                              to_state: new_state}}
    Logger.debug("Broadcast on #{inspect topic}: #{inspect message}")
    Phoenix.PubSub.broadcast(Metrist.PubSub, topic, message)
  end

  defp timeout_for(:alive), do: @alive_timeout
  defp timeout_for(:dormant), do: @dormant_timeout

  defp topic_for(account_uuid), do: "nodes:#{account_uuid}"
end
