defmodule MetristWeb.NodeSeriesLive do
  use Phoenix.LiveView

  # Render a set of metrics on a dashboard.

  @impl true
  def render(assigns) do
    ~L"""
    <%= for field <- @fields do %>
      <%= id = @series <> "." <> field
          live_component @socket, MetristWeb.ChartComponent, id: id, series: @series, field: field %>
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
    |> assign_fields()
    {:noreply, socket}
  end
  def handle_params(params = %{"agent" => _}, _uri, socket) do
    IO.puts("Handle Params: #{inspect params}")
    socket = socket
    |> assign(:agent, params["agent"])
    |> assign(:series, params["series"])
    |> assign_fields()
    {:noreply, socket}
  end

  defp assign_fields(socket) do
    fields = Metrist.InfluxStore.fields_of(socket.assigns.series)
    fields = Enum.map(fields, fn [field_name, _type] -> field_name end)
    assign(socket, :fields, fields)
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
