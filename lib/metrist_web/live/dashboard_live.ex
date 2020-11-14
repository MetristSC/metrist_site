defmodule MetristWeb.DashboardLive do
  use Phoenix.LiveView

  alias MetristWeb.Router.Helpers, as: Routes

  def render(assigns) do
    ~L"""
    <%= if is_nil(@agents) or MapSet.size(@agents) == 0 do %>
    (Waiting for agents to register)
    <% else %>
    <table class="border border-gray-500">
      <tr class="bg-indigo-300">
        <th>Agent</th>
        <th>Series</th>
      </tr>
      <%= for agent <- @agents do %>
      <tr>
        <td class="border p-2"><%= agent %></td>
        <td class="border p-2">
          <% series = Metrist.InfluxStore.series_of(@account_uuid, agent) %>
          <%= for serie <- series do %>
            <%= live_redirect to: Routes.live_path(@socket, MetristWeb.AgentSeriesLive, agent, serie) do %>
              <div style="cursor: pointer"><%= serie %></div>
            <% end %>
          <% end %>
        </td>
      </tr>
      <% end %>
    </table>
    <% end %>
    <div class="mt-2">
    Your API key: <%= @api_key %>
    </div>
    """
  end

  def mount(_params, session = %{"current_user" => _}, socket) do
    pid = self()
    if connected?(socket) do
      Task.async(fn -> poll_for_data(pid, session["current_user"]) end)
    else
      IO.puts("Hmm... socket not connected...")
      IO.puts("#{inspect socket}")
    end
    socket = socket
    |> assign(:current_user, session["current_user"])
    |> assign(:owner_uuid, "Fetching...")
    |> assign(:account_uuid, "Fetching...")
    |> assign(:api_key, "Fetching...")
    |> assign(:agents, MapSet.new())
    {:ok, socket}
  end
  def mount(_params, _session, socket) do
    {:ok, redirect(socket, to: "/")}
  end

  def handle_info({:owner_uuid, owner_uuid}, socket) do
    {:noreply, assign(socket, :owner_uuid, owner_uuid)}
  end

  def handle_info({:account_uuid, account_uuid}, socket) do
    agents = account_uuid
    |> Metrist.Agent.PresenceSupervisor.all_for()
    |> Enum.map(fn {agent, _pid} -> agent end)
    |> MapSet.new()
    Metrist.Agent.Presence.subscribe(account_uuid)
    socket = socket
    |> assign(:account_uuid, account_uuid)
    |> assign(:agents, agents)
    {:noreply, socket}
  end

  def handle_info({:api_key, api_key}, socket) do
    {:noreply, assign(socket, :api_key, api_key)}
  end
  def handle_info({:agent_state_change, agent_data}, socket) do
    current_agents = socket.assigns.agents
    current_agents = if agent_data.to_state == :inactive do
      MapSet.delete(current_agents, agent_data.agent_id)
    else
      MapSet.put(current_agents, agent_data.agent_id)
    end
    {:noreply, assign(socket, :agents, current_agents)}
  end

  def handle_info(msg, socket) do
    IO.puts("Hmm... #{inspect msg}")
    {:noreply, socket}
  end


  def handle_event("showseries", %{"agent" => agent, "serie" => serie}, socket) do
    socket = socket
    |> push_redirect(to: MetristWeb.Router.Helpers.live_path(socket, MetristWeb.AgentSeriesLive,
        agent, serie))
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
