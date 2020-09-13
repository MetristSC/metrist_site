defmodule MetristWeb.DashboardLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    Current temperature: <%= @temperature %>
    """
  end

  def mount(params, stuff, socket) do
    IO.puts("live dashboard mounted, params = #{inspect params}")
    IO.puts("                  stuff = #{inspect stuff}")
    IO.puts("                 socket = #{inspect socket}")
    temperature = 42
    {:ok, assign(socket, :temperature, temperature)}
  end
end
