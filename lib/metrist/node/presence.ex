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
  use GenServer, restart: :transient
  require Logger
  alias Metrist.Node.Command

if Mix.env == :dev do
  @alive_timeout 30_000
  @dormant_timeout 60_000
else
  @alive_timeout 60_000
  @dormant_timeout 86_400_000
end

  defmodule State do
    defstruct [:account_uuid, :node_id, :node_uuid, :state, :timer_ref]
  end


  def start_link([account_uuid, node_id, name]) do
    GenServer.start_link(__MODULE__, [account_uuid, node_id], name: name)
  end

  @doc """
  Register a received ping. Starts a server if needed.
  """
  def ping_received(account_uuid, node_id) do
    # TODO not sure this is the perfect spot...
    if not exists?(account_uuid, node_id) do
      c = %Command.Create{
        uuid: Id.generate(),
        account_uuid: account_uuid,
        node_id: node_id}
      Logger.info("Node does not exist, dispatching command #{inspect c}")
      Metrist.App.dispatch(c)
    end

    server = Metrist.Node.PresenceSupervisor.find_or_start_child(account_uuid, node_id)
    Logger.info("Processing ping for #{account_uuid}/#{node_id} to #{inspect server}")
    result = GenServer.cast(server, :ping_received)
    Logger.info("Ping result: #{inspect result}")
    result
  end

  @doc """
  Subscribe to all _node_ presence messages for the given account.
  """
  def subscribe(account_uuid) do
    Metrist.PubSub.subscribe("nodes", account_uuid)
  end

  # Server side

  @impl true
  def init([account_uuid, node_id]) do
    Logger.info("Initializing presence server at #{inspect self()} for #{account_uuid},#{node_id}")
    state = %State{account_uuid: account_uuid,
                   node_id: node_id,
                   state: :new}
    broadcast_state_change(state, :alive)
    state = schedule_timeout(state, :alive)
    {:ok, state}
  end

  @impl true
  def handle_cast(:ping_received, state) do
    Logger.info("Server processing ping for #{inspect state}")
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
    message = {:node_state_change, %{account_uuid: state.account_uuid,
                              node_id: state.node_id,
                              to_state: new_state}}
    Logger.debug("#{inspect self()} broadcast on #{inspect state.account_uuid} from state #{state.state}: #{inspect message}")
    Metrist.PubSub.broadcast("nodes", state.account_uuid, message)
  end

  defp timeout_for(:alive), do: @alive_timeout
  defp timeout_for(:dormant), do: @dormant_timeout

  defp exists?(account_uuid, node_id) do
    Metrist.Node.Projection.by_account_and_node_id(account_uuid, node_id)
    |> Metrist.Repo.exists?()
  end

  defp dispatch_handle_ping_command(state) do
    node = Metrist.Node.Projection.by_account_and_node_id(state.account_uuid, state.node_id)
    |> Metrist.Repo.one()
    if node do
      c = %Command.HandlePing{uuid: node.uuid}
      Logger.debug("Dispatching command #{inspect c}")
      Metrist.App.dispatch(c)
    else
      # and if not? We'll wait until registration is complete and do it the next round.
      Logger.debug("Node not registered yet, skipping ping command")
    end
  end
end
