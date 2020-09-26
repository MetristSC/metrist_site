defmodule MetristWeb.DashboardLive do
  use Phoenix.LiveView

  def render(assigns) do
    IO.puts("rendering with assigns: #{inspect assigns}")
    ~L"""
    Owner UUID: <%= @owner_uuid %>
    <br>
    Account UUID: <%= @account_uuid %>
    <br>
    API Key: <%= @api_key %>
    <br>
    Agent(s) known: <%= inspect(@nodes) %>
    """
  end

  def mount(_params, session, socket) do
    pid = self()
    if connected?(socket) do
      Task.async(fn -> poll_for_data(pid, session["current_user"]) end)
    else
      IO.puts("Hmm... socket not connected...")
      IO.puts("#{inspect socket}")
    end
    socket = socket
    |> assign(:owner_uuid, "Fetching...")
    |> assign(:account_uuid, "Fetching...")
    |> assign(:api_key, "Fetching...")
    |> assign(:nodes, [])
    {:ok, socket}
  end

  def handle_info({:owner_uuid, owner_uuid}, socket) do
    {:noreply, assign(socket, :owner_uuid, owner_uuid)}
  end

  def handle_info({:account_uuid, account_uuid}, socket) do
    nodes = account_uuid
    |> Metrist.Node.PresenceSupervisor.all_for()
    |> Enum.map(fn {node, _pid} -> node end)
    |> MapSet.new()
    Metrist.Node.Presence.subscribe(account_uuid)
    socket = socket
    |> assign(:account_uuid, account_uuid)
    |> assign(:nodes, nodes)
    {:noreply, socket}
  end

  def handle_info({:api_key, api_key}, socket) do
    {:noreply, assign(socket, :api_key, api_key)}
  end
  def handle_info({:node_state_change, node_data}, socket) do
    current_nodes = socket.assigns.nodes
    current_nodes = if node_data.to_state == :inactive do
      MapSet.delete(current_nodes, node_data.node_id)
    else
      MapSet.put(current_nodes, node_data.node_id)
    end
    {:noreply, assign(socket, :nodes, current_nodes)}
  end

  def handle_info(msg, socket) do
    IO.puts("Hmm... #{inspect msg}")
    {:noreply, socket}
  end

  # Ok, not super clean, but I'm curious how far we can take
  # this and delays setting up a registry for a bit.
  # TODO cleanup
  defp poll_for_data(pid, user) do
    # Step one: owner uuid. We might be in a registration
    # so the uuid might not be there.
    owner_uuid = poll_for_owner_uuid(pid, user)
    # Same for account id and default api key
    account_uuid = poll_for_account_uuid(pid, owner_uuid)
    poll_for_api_key(pid, account_uuid)
    "Polling done. Maybe fix this hack"
  end

  defp poll_for_owner_uuid(pid, user) do
    result =
      Metrist.User.Projection.by_provider_and_id(
        to_string(user.provider),
        to_string(user.id))
      |> Metrist.Repo.one()
    if result == nil do
      Process.sleep(1_000)
      poll_for_owner_uuid(pid, user)
    else
      send(pid, {:owner_uuid, result})
      result
    end
  end
  defp poll_for_account_uuid(pid, owner_uuid) do
    result =
      Metrist.Account.Projection.ByOwner.by_owner(owner_uuid)
      |> Metrist.Repo.one()
    if result == nil do
      Process.sleep(1_000)
      poll_for_account_uuid(pid, owner_uuid)
    else
      send(pid, {:account_uuid, result})
      result
    end
  end
  defp poll_for_api_key(pid, account_uuid) do
    result =
      Metrist.Account.Projection.ByApiKey.api_keys(account_uuid)
      |> Metrist.Repo.one()
    if result == nil do
      Process.sleep(1_000)
      poll_for_api_key(pid, account_uuid)
    else
      send(pid, {:api_key, result})
      result
    end
  end
end
