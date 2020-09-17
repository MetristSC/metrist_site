defmodule MetristWeb.PingController do
  @moduledoc """
  Controller that receives agent pings.
  """
  use MetristWeb, :controller
  require Logger

  def index(conn, params) do
    Logger.info("Ping received! #{inspect params}")
    Logger.info("     #{inspect conn}")
    # TODO API verification, start a server, etcetera.
    text(conn, "pong")
  end
end
