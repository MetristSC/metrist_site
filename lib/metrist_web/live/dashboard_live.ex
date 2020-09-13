defmodule MetrisWeb.DashboardLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    Current temperature: <%= @temperature %>
    """
  end

  def mount(_params, _stuff, socket) do
    temperature = 42
    {:ok, assign(socket, :temperature, temperature)}
  end
end
