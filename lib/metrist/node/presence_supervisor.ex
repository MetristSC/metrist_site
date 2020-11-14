defmodule Metrist.Node.PresenceSupervisor do
  @moduledoc """
  Supervisor for presence monitoring processes.
  """
  use DynamicSupervisor
  require Logger

  @registry Module.concat(__MODULE__, Registry)

  def start_link(init_arg) do
    {:ok, _} = Registry.start_link(keys: :unique, name: @registry)
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @doc """
  Find the running process for the node or start a new one.
  """
  def find_or_start_child(account_uuid, node_id) do
    case Registry.lookup(@registry, {account_uuid, node_id}) do
      [{pid, _}] ->
        Logger.info("Presence server for #{node_id} is #{inspect pid}")
        make_name(account_uuid, node_id)
      [] ->
        start_child(account_uuid, node_id)
    end
  end

  @doc """
  Return all processes for the account as a list of `{uuid, pid}` pairs.
  """
  def all_for(account_uuid) do
    pattern = {{:"$1", :"$2"}, :"$3", :_}
    guards = [{:==, :"$1", account_uuid}]
    body = [{{:"$2", :"$3"}}]
    Registry.select(@registry,
      [{pattern, guards, body}]
    )
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  defp start_child(account_uuid, node_id) do
    name = make_name(account_uuid, node_id)
    spec = {Metrist.Node.Presence, [account_uuid, node_id, name]}

    case DynamicSupervisor.start_child(__MODULE__, spec) do
      {:ok, _pid} ->
        Logger.info("Started new presence server at #{inspect name}")
        name
      {:error, {:already_started, _pid}} ->
        Logger.info("Presence server for #{inspect name} already exists")
        name
      {:error, reason} ->
        raise("Could not start child, reason: #{inspect(reason)}")
    end
  end

  defp make_name(account_uuid, node_id) do
    # TODO maybe just use the Node's UUID?
    {:via, Registry, {@registry, {account_uuid, node_id}}}
  end
end
