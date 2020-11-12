defmodule MetristWeb.NodeSeriesLive do
  use Phoenix.LiveView

  # Render a set of metrics on a dashboard.

  @impl true
  def render(assigns) do
    ~L"""
    <%= for [metric, _type] <- Metrist.InfluxStore.fields_of(@series) do %>
      <%= id = @series <> "." <> metric
          live_component @socket, MetristWeb.ChartComponent, id: id, series: @series, metric: metric %>
    <% end %>
    <br>
    <%= inspect assigns %>
    We should graph: <%= inspect Metrist.InfluxStore.fields_of(@series) %>
    """
  end

  @impl true
  def handle_params(params = %{"agent_name" => _}, _uri, socket) do
    IO.puts("Handle Params: #{inspect params}")
    socket = socket
    |> assign(:agent, params["agent_name"])
    |> assign(:series, params["agent_uuid"] <> "/" <> params["agent_name"] <> "/" <> params["series_name"])
    {:noreply, socket}
  end
  def handle_params(params = %{"agent" => _}, _uri, socket) do
    IO.puts("Handle Params: #{inspect params}")
    socket = socket
    |> assign(:agent, params["agent"])
    |> assign(:series, params["series"])
    {:noreply, socket}
  end

  # TODO one day we need security checks here.
  @impl true
  def mount(_params, session, socket) do
    IO.puts("Session: #{inspect session}")
    IO.puts("Socket assigns: #{inspect socket.assigns}")
    socket = socket
    |> assign(:current_user, session["current_user"])
    {:ok, socket}
  end
end
