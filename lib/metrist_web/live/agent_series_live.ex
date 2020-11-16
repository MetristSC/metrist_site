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
    ~L"""
    <div class="pl-4 text-lg">Metrics for <%= @series %>.
      <%= render_button(@alive?, @streaming?, assigns) %></div>
    <div class="grid grid-cols-2 gap-2">
    <%= for field <- @fields do %>
      <div class="bg-white m-2 p-2 rounded-2xl shadow-xl">
        <%= id = @series <> "." <> field
            live_component @socket, MetristWeb.ChartComponent, id: id, series: @series, field: field,
              alive?: @alive?, account_uuid: @account_uuid, agent_name: @agent_name %>
      </div>
    <% end %>
    </div>
    """
  end

  # See the router. Because of the slashes in the full series name, we can expect either
  # variant. Handle both for now, but TODO is maybe reconsider using slashes as separators.
  @impl true
  def handle_params(params, _uri, socket) do
    series_name = Series.full_name(params)
    fields = Metrist.InfluxStore.fields_of(series_name)
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
    |> assign(:series, series_name)
    |> assign(:series_name, params["series_name"])
    |> assign(:fields, fields)
    |> assign(:alive?, Metrist.Agent.Presence.alive?(params["account_uuid"], params["agent_name"]))
    |> assign(:streaming?, false)
    for field <- fields do
      id = "#{socket.assigns.series}.#{field}"
      send_update(MetristWeb.ChartComponent, id: id,
        data: Metrist.InfluxStore.values_for(series_name, field, :microsecond))
    end
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
    |> handle_fields_and_values(socket)
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
  def handle_event(event, value, socket) do
    IO.puts("HANDLE ME: #{inspect event}, #{inspect value}")
    {:noreply, socket}
  end

  defp handle_fields_and_values(nil, socket), do: socket
  defp handle_fields_and_values([ts, fv_map, _tags], socket) do
    ts = Metrist.Timestamps.to(ts, :microsecond)
    for {field, value} <- fv_map do
      id = "#{socket.assigns.series}.#{field}"
      send_update(MetristWeb.ChartComponent, id: id, data: [[ts, value]])
    end
  end

  def render_button(_alive = true, _streaming = false, assigns) do
    ~L(<button phx-click="start-streaming">Start streaming</button>)
  end
  def render_button(_alive = true, _streaming = true, assigns) do
    ~L(<button phx-click="stop-streaming">Stop streaming</button>)
  end
  def render_button(_alive = false, _streaming, _assigns) do
    "(agent is not alive)"
  end

end
