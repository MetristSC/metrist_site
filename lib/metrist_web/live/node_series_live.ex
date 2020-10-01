defmodule MetristWeb.NodeSeriesLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    Series here.
    <br>
    <%= inspect assigns %>
    """
  end

  def mount(params, session, socket) do
    IO.puts("Params: #{inspect params}")
    IO.puts("Session: #{inspect session}")
    IO.puts("Socket assigns: #{inspect socket.assigns}")
    {:ok, socket}
  end
end
