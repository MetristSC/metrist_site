defmodule MetristWeb.AgentSeriesLive do
  use Phoenix.LiveView
  require Logger

  alias MetristWeb.Series

  @moduledoc """
  Render a set of metrics on a dashboard.
  """

  # TODO verify that current user has access to the agent

  @impl true
  def render(assigns) do
    # TODO CSS here can be cleaner.
    ~L"""
    <div class="flex flex-row">
      <div class="flex-grow pl-4 text-lg">Metrics for <%= @series %>.</div>
      <div class="ml-4 mr-4"><%= render_button(@alive?, @streaming?, assigns) %></div>
      <div>
        <select phx-click="change-interval">
          <option value="24h">Last 24h</option>
          <option value="12h">Last 12h</option>
          <option value="1h">Last hour</option>
          <option value="5m">Last 5m</option>
          <option value="all">All time</option>
        </select>
      </div>
    </div>
    <div class="flex flex-row flex-wrap">
    <%= for field <- @fields do %>
      <div class="bg-white m-2 p-2 rounded-2xl shadow-xl" style="flex: 1 0 50%; max-width: 650px; min-width: 550px">
        <%= id = @series <> "." <> field
            live_component @socket, MetristWeb.ChartComponent, id: id, series: @series, field: field,
              alive?: @alive?, account_uuid: @account_uuid, agent_name: @agent_name %>
      </div>
    <% end %>
    </div>
    <div class="text-center font-thin">(drag to zoom, double-click to reset zoom)</div>
    """
  end

  # See the router. Because of the slashes in the full series name, we can expect either
  # variant. Handle both for now, but TODO is maybe reconsider using slashes as separators.
  @impl true
  def handle_params(params, _uri, socket) do
    full_series_name = Series.full_name(params)
    fields = Metrist.InfluxStore.fields_of(full_series_name)
    fields = Enum.map(fields, fn [field_name, _type] -> field_name end)
    # TODO move this out of the _web app
    agent = Metrist.Agent.Projection.by_account_and_agent_id(params["account_uuid"], params["agent_name"])
    |> Metrist.Repo.one!()
    # TODO maybe move this out to presence.ex?
    Metrist.PubSub.subscribe("agents", params["account_uuid"])
    socket = socket
    |> assign(:agent_name, params["agent_name"])
    |> assign(:agent_uuid, agent.uuid)
    |> assign(:account_uuid, params["account_uuid"])
    |> assign(:series, full_series_name)
    |> assign(:series_name, params["series_name"])
    |> assign(:fields, fields)
    |> assign(:alive?, Metrist.Agent.Presence.alive?(params["account_uuid"], params["agent_name"]))
    |> assign(:streaming?, false)
    |> assign(:interval, "24h")
    load_data(socket)
    Metrist.PubSub.subscribe("agent", agent.uuid)
    {:noreply, socket}
  end

  @impl true
  def mount(_params, session = %{"current_user" => _}, socket) do
    socket = socket
    |> assign(:current_user, session["current_user"])
    {:ok, socket}
  end
  def mount(_params, _session, socket) do
    {:ok, redirect(socket, to: "/")}
  end

  @impl true
  def terminate(_reason, socket) do
    Metrist.Agent.Presence.stop_streaming(socket.assigns.account_uuid, socket.assigns.agent_name)
    :ok
  end

  @impl true
  def handle_info({:metrics_received, metrics}, socket) do
    metrics
    |> Map.get(socket.assigns.series_name)
    |> send_incremental_data(socket)
    {:noreply, socket}
  end
  def handle_info({:agent_state_change, info}, socket) do
    agent_id = Map.get(info, :agent_id)
    socket = if agent_id == socket.assigns.agent_name do
      is_alive = Map.get(info, :to_state) == :alive
      socket = assign(socket, :alive?, is_alive)
      for field <- socket.assigns.fields do
        id = socket.assigns.series <> "." <> field
        send_update(MetristWeb.ChartComponent, id: id, alive?: is_alive)
      end
      socket
    else
      socket
    end
    {:noreply, socket}
  end
  def handle_info(msg, socket) do
    Logger.error("Received unhandled message: #{inspect msg}")
    {:noreply, socket}
  end

  @impl true
  def handle_event("start-streaming", _value, socket) do
    Metrist.Agent.Presence.start_streaming(socket.assigns.account_uuid, socket.assigns.agent_name)
    socket = assign(socket, :streaming?, true)
    {:noreply, socket}
  end
  @impl true
  def handle_event("stop-streaming", _value, socket) do
    Metrist.Agent.Presence.stop_streaming(socket.assigns.account_uuid, socket.assigns.agent_name)
    socket = assign(socket, :streaming?, false)
    {:noreply, socket}
  end
  def handle_event("change-interval", value, socket) do
    selected_interval = value["value"]
    socket = if socket.assigns.interval != selected_interval do
      socket = assign(socket, :interval, selected_interval)
      load_data(socket)
      socket
    else
      socket
    end
    {:noreply, socket}
  end
  def handle_event(event, value, socket) do
    Logger.error("HANDLE ME: #{inspect event}, #{inspect value}")
    {:noreply, socket}
  end

  defp send_incremental_data(nil, socket), do: socket
  defp send_incremental_data([ts, fv_map, _tags], socket) do
    ts = Metrist.Timestamps.to(ts, :microsecond)
    for {field, value} <- fv_map do
      id = "#{socket.assigns.series}.#{field}"
      send_update(MetristWeb.ChartComponent, id: id, clear: false, data: [[ts, value]])
    end
  end

  def render_button(_alive = true, _streaming = false, assigns) do
    ~L(<button phx-click="start-streaming" class="hover:font-bold">Start streaming</button>)
  end
  def render_button(_alive = true, _streaming = true, assigns) do
    ~L(<button phx-click="stop-streaming" class="hover:font-bold">Stop streaming</button>)
  end
  def render_button(_alive = false, _streaming, _assigns) do
    "(agent is not alive)"
  end

  defp load_data(socket) do
    delta = interval_for(socket.assigns.interval)
    stop = :erlang.system_time(:second)
    start = stop - delta
    for field <- socket.assigns.fields do
      id = "#{socket.assigns.series}.#{field}"
      send_update(MetristWeb.ChartComponent, id: id,
        clear: true,
        data: Metrist.InfluxStore.values_for(socket.assigns.series, field, {start, stop}, :microsecond))
    end
  end

  defp interval_for("24h"), do: 24 * 3600
  defp interval_for("12h"), do: 12 * 3600
  defp interval_for("1h"), do: 1 * 3600
  defp interval_for("5m"), do: 5 * 60
end
