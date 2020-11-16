defmodule MetristWeb.ChartComponent do
  use Phoenix.LiveComponent
  require Logger

  @impl true
  def preload(list_of_assigns) do
    # A potential optimization here is to load everything with one call to InfluxDB
    list_of_assigns
  end

  @impl true
  def mount(socket) do
    # TODO We can optimize here to get all the data in one call from InfluxDB
    {:ok, socket, temporary_assigns: [data: []]}
  end

  @impl true
  def update(assigns, socket) do
    {series, assigns} = Map.pop(assigns, :series)
    socket = if series do
      # Initial call
      assign(socket,
        series: series,
        field: assigns.field,
        id: assigns.id,
        data: [])
    else
      # Data update call
      assign(socket, data: assigns.data)
    end
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div id="chart-<%= @id %>">
      <div phx-hook="PhxChartComponent" id="chart-<%= @id %>--datasets" style="display:none;">
      <%= for [time, value] <- assigns.data do %>
        <span data-x="<%= @field %>" data-y="<%= value %>" data-z="<%= time %>"></span>
      <% end %>
      </div>
      <div class="chart"
          id="chart-ignore-<%= @id %>"
          phx-update="ignore"
          data-label="<%= @field %>"
          data-metric="<%= "summary" %>"
          data-title="<%= @field %>"
          data-tags="<%= "" %>"
          data-unit="B"
          data-prune-threshold="1000">
      </div>
    </div>
    """
  end
end
