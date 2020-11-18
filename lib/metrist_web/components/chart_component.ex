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
    {:ok, socket, temporary_assigns: [data: []]}
  end

  @impl true
  def update(assigns, socket) do
    {series, assigns} = Map.pop(assigns, :series)
    socket = if series do
      # Initial call
      assign(socket,
        account_uuid: assigns.account_uuid,
        agent_name: assigns.agent_name,
        series: series,
        field: assigns.field,
        id: assigns.id,
        alive?: assigns.alive?,
        clear: true,
        data: [])
    else
      # Update call
      socket = if Map.has_key?(assigns, :data), do: assign(socket, data: assigns.data), else: socket
      socket = if Map.has_key?(assigns, :clear), do: assign(socket, clear: assigns.clear), else: socket
      socket
    end
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div id="chart-<%= @id %>">
      <div phx-hook="PhxChartComponent" id="chart-<%= @id %>--datasets" style="display:none;">
      <%= for [time, value] <- @data do %>
        <span data-x="<%= @field %>" data-y="<%= value %>" data-z="<%= time %>"></span>
      <% end %>
      </div>
      <div class="chart"
          id="chart-ignore-<%= @id %>"
          phx-update="ignore"
          data-label="<%= @field %>"
          data-metric="last_value"
          data-title="<%= @field %>"
          data-tags=""
          data-unit=""
          data-clear="<%= @clear %>"
          data-prune-threshold="1000">
      </div>
    </div>
    """
  end
end
