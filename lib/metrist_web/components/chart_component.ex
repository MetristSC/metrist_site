# This code was originally lifted from Phoenix LiveView Dashboard.
# The license and original URL are reproduced on the bottom of this file.
defmodule MetristWeb.ChartComponent do
  use Phoenix.LiveComponent

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
    <div id="chart-<%= @id %>">
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
          data-title="<%= @field %>"
          data-tags="<%= "" %>"
          data-unit="B"
          data-prune-threshold="1000">
      </div>
    </div>
    """
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
