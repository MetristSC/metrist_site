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
    agent_id = params["agent_id"]

    Metrist.Agent.Presence.ping_received(account_uuid, agent_id)
    handle_payload(account_uuid, agent_id, params["payload"])
    :ok
  end

  defp handle_payload(_account_uuid, _agent_id, nil), do: :ok
  defp handle_payload(account_uuid, agent_id, payload) do
    agent = Metrist.Agent.Projection.by_account_and_agent_id(account_uuid, agent_id)
    |> Metrist.Repo.one()
    Logger.info("Agent is: #{inspect agent}")
    if agent do
      Logger.info("We have a agent uuid, can broadcast and write")
      Metrist.PubSub.broadcast("agent", agent.uuid, {:metrics_received, payload})
      Metrist.InfluxStore.write_from_agent(account_uuid, agent.agent_id, payload)
    end
  end
end
