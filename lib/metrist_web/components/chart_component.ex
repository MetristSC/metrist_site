# This code was originally lifted from Phoenix LiveView Dashboard.
# The license and original URL are reproduced on the bottom of this file.
defmodule MetristWeb.ChartComponent do
  use Phoenix.LiveComponent

  @default_prune_threshold 1_000

  @impl true
  def mount(socket) do
    {:ok, socket, temporary_assigns: [data: []]}
  end

  #@impl true
  #def update(assigns, socket) do
    # {metric, assigns} = Map.pop(assigns, :metric)
#
    #socket =
      #if metric do
        #assign(socket,
          #title: chart_title(metric),
          #description: metric.description,
          #kind: chart_kind(metric.__struct__),
          #label: chart_label(metric),
          #tags: Enum.join(metric.tags, "-"),
          #unit: chart_unit(metric.unit),
          #prune_threshold: prune_threshold(metric)
        #)
      #else
        #socket
      #end
#
    # {:ok, assign(socket, assigns)}
  #end

  @impl true
  def render(assigns) do
    # TODO move this to a push update style.
    data = Metrist.InfluxStore.values_for(assigns.series, assigns.field)
    ~L"""
    <div class="">
      <div id="chart-<%= @id %>" class="card">
        <div class="card-body">
          <div phx-hook="PhxChartComponent" id="chart-<%= @id %>--datasets" style="display:none;">
          <%= for [time, value] <- data do %>
            <span data-x="<%= @field %>" data-y="<%= value %>" data-z="<%= time %>"></span>
          <% end %>
          </div>
          <div class="chart"
              id="chart-ignore-<%= @id %>"
              phx-update="ignore"
              data-label="<%= @field %>"
              data-metric="<%= "summary" %>"
              data-title="<%= "#{@series}.#{@field}" %>"
              data-tags="<%= "" %>"
              data-unit="KB"
              data-prune-threshold="10000">
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp chart_title(metric) do
    "#{Enum.join(metric.name, ".")}#{chart_tags(metric.tags)}"
  end

  defp chart_tags([]), do: ""
  defp chart_tags(tags), do: " (#{Enum.join(tags, "-")})"

  defp chart_kind(Telemetry.Metrics.Counter), do: :counter
  defp chart_kind(Telemetry.Metrics.LastValue), do: :last_value
  defp chart_kind(Telemetry.Metrics.Sum), do: :sum
  defp chart_kind(Telemetry.Metrics.Summary), do: :summary

  defp chart_kind(Telemetry.Metrics.Distribution),
    do: raise(ArgumentError, "LiveDashboard does not yet support distribution metrics")

  defp chart_label(%{} = metric) do
    metric.name
    |> List.last()
    |> Phoenix.Naming.humanize()
  end

  defp chart_unit(:byte), do: "bytes"
  defp chart_unit(:kilobyte), do: "KB"
  defp chart_unit(:megabyte), do: "MB"
  defp chart_unit(:nanosecond), do: "ns"
  defp chart_unit(:microsecond), do: "µs"
  defp chart_unit(:millisecond), do: "ms"
  defp chart_unit(:second), do: "s"
  defp chart_unit(:unit), do: ""
  defp chart_unit(unit) when is_atom(unit), do: unit

  defp prune_threshold(metric) do
    prune_threshold =
      metric.reporter_options[:prune_threshold]
      |> validate_prune_threshold()

    to_string(prune_threshold || @default_prune_threshold)
  end

  defp validate_prune_threshold(nil), do: nil

  defp validate_prune_threshold(value) do
    unless is_integer(value) and value > 0 do
      raise ArgumentError,
            "expected :prune_threshold to be a positive integer, got: #{inspect(value)}"
    end

    value
  end
end

# Original URL: https://github.com/phoenixframework/phoenix_live_dashboard/
#
# MIT License
#
#Copyright (c) 2019 Michael Crumm, Chris McCord, José Valim
#
#Permission is hereby granted, free of charge, to any person obtaining
#a copy of this software and associated documentation files (the
#"Software"), to deal in the Software without restriction, including
#without limitation the rights to use, copy, modify, merge, publish,
#distribute, sublicense, and/or sell copies of the Software, and to
#permit persons to whom the Software is furnished to do so, subject to
#the following conditions:
#
#The above copyright notice and this permission notice shall be
#included in all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
#NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
#LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
#OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
#WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
