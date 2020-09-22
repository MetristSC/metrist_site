defmodule MetristWeb.PingController do
  @moduledoc """
  Controller that receives agent pings.
  """
  use MetristWeb, :controller
  require Logger

  def index(conn, params) do
    Logger.info("Ping received! #{inspect params}")
    Logger.info("     #{inspect conn}")
    case verify_request(params) do
      :ok -> text(conn, "pong")
      error  -> text(conn, error)
    end
    # TODO API verification, start a server, etcetera.
  end

  defp verify_request(%{"api_key" => api_key,
                       "payload" => payload} = params) do
    account = Metrist.Account.Projection.ByApiKey.by_api_key(api_key)
    |> Metrist.Repo.one()
    verify_request(account, payload, params)
  end
  defp verify_request(params) do
    Logger.info("Invalid request #{inspect params}")
    :invalid_request
  end

  def verify_request(nil, _payload, params) do
    Logger.info("Unknown API key/account #{inspect params}")
    :unkown_key
  end

  def verify_request(acct, _payload, params) do
    Logger.debug("Valid request for account #{inspect acct}")
    Metrist.Node.NodePing.ping_received(acct.account_uuid,
      params["node_id"])
    :ok
  end

end
