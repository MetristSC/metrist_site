defmodule MetristWeb.AgentSeriesLive do
  use Phoenix.LiveView

  @moduledoc """
  Render a set of metrics on a dashboard.
  """

  # TODO verify that current user has access to the agent

  @impl true
  def render(assigns) do
    ~L"""
    <div class="pl-4 text-lg">Metrics for <%= @series %></div>
    <div class="grid grid-cols-2 gap-2">
    <%= for field <- @fields do %>
      <div class="bg-white m-2 p-2 rounded-2xl shadow-xl">
        <%= id = @series <> "." <> field
            live_component @socket, MetristWeb.ChartComponent, id: id, series: @series, field: field %>
      </div>
    <% end %>
    </div>
    """
  end

  # See the router. Because of the slashes in the full series name, we can expect either
  # variant.
  @impl true
  def handle_params(params = %{"agent_name" => _}, _uri, socket) do
    params
    |> Map.put("series", "#{params["account_uuid"]}/#{params["agent_name"]}/#{params["series_name"]}")
    |> do_handle_params(socket)
  end
  def handle_params(params = %{"agent" => _}, _uri, socket) do
    [account_uuid, agent_name, _] = String.split(params["series"], "/")
    params
    |> Map.put("agent_name", agent_name)
    |> Map.put("account_uuid", account_uuid)
    |> do_handle_params(socket)
  end
  defp do_handle_params(params, socket) do
    IO.puts("Do handle Params: #{inspect params}")
    fields = Metrist.InfluxStore.fields_of(params["series"])
    fields = Enum.map(fields, fn [field_name, _type] -> field_name end)
    # TODO move this out of the _web app
    agent = Metrist.Agent.Projection.by_account_and_agent_id(params["account_uuid"], params["agent_name"])
    |> Metrist.Repo.one!()
    socket = socket
    |> assign(:agent_name, params["agent_name"])
    |> assign(:agent_uuid, agent.uuid)
    |> assign(:account_uuid, params["account_uuid"])
    |> assign(:series, params["series"])
    |> assign(:fields, fields)
    Metrist.PubSub.subscribe("agent", agent.uuid)
    {:noreply, socket}
  end

  @impl true
  def mount(_params, session = %{"current_user" => _}, socket) do
    IO.puts("Session: #{inspect session}")
    IO.puts("Socket assigns: #{inspect socket.assigns}")
    socket = socket
    |> assign(:current_user, session["current_user"])
    {:ok, socket}
  end
  def mount(_params, _session, socket) do
    {:ok, redirect(socket, to: "/")}
  end

  @impl true
  def handle_info(msg, socket) do
    IO.puts("Received unhandled message: #{inspect msg}")
    {:noreply, socket}
  end
end
