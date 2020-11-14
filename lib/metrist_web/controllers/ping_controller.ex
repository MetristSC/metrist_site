defmodule MetristWeb.PingController do
  @moduledoc """
  Controller that receives agent pings.
  """
  use MetristWeb, :controller
  require Logger

  def index(conn, params) do
    case verify_request(params) do
      :ok -> text(conn, "pong")
      error  -> text(conn, error)
    end
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
    account_uuid = acct.account_uuid
    node_id = params["node_id"]

    Metrist.Node.Presence.ping_received(account_uuid, node_id)
    handle_payload(account_uuid, node_id, params["payload"])
    :ok
  end

  defp handle_payload(_account_uuid, _node_id, nil), do: :ok
  defp handle_payload(account_uuid, node_id, payload) do
    node = Metrist.Node.Projection.by_account_and_node_id(account_uuid, node_id)
    |> Metrist.Repo.one()
    Logger.info("Node is: #{inspect node}")
    if node do
      Logger.info("We have a node uuid, can broadcast and write")
      Metrist.PubSub.broadcast("agent", node.uuid, {:metrics_received, payload})
      Metrist.InfluxStore.write_from_agent(account_uuid, node.node_id, payload)
    end
  end
end
