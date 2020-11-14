defmodule MetristWeb.ChartComponent do
  use Phoenix.LiveComponent
  require Logger

  @impl true
  def preload(list_of_assigns) do
    Logger.debug("Chart preload(#{inspect list_of_assigns}")
    list_of_assigns
  end

  @impl true
  def mount(socket) do
    # TODO We can optimize here to get all the data in one call from InfluxDB
    Logger.info("Chart mount(#{inspect socket}")
    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    Logger.info("Chart update(#{inspect assigns}, #{inspect socket}")
    {series, assigns} = Map.pop(assigns, :series)
    socket = if series do
      # Initial call
      data = Metrist.InfluxStore.values_for(series, assigns.field)
      assign(socket,
        series: series,
        field: assigns.field,
        id: assigns.id,
        data: data)
    else
      # Data update call
      assign(socket, data: assigns.data)
    end
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    Logger.info("Chart render(#{inspect assigns}")
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
