defmodule Metrist.Agent.Projector do
  use Commanded.Projections.Ecto,
    application: Metrist.App,
    repo: Metrist.Repo,
    name: "agents_projector"

  alias Metrist.Agent.Event
  require Logger

  project e = %Event.Created{}, fn multi ->
    if not exists?(e.uuid) do
      Logger.info("=== Making")
      Logger.info("??? #{inspect %Metrist.Agent.Projection{}}")
      p = %Metrist.Agent.Projection{uuid: e.uuid,
                                   account_uuid: e.account_uuid,
                                   agent_id: e.agent_id}
      Logger.info("<<< #{inspect p}")
      r = Ecto.Multi.insert(multi, :agent, p)
      Logger.info(">>> #{inspect r}")
      r
    else
      # Ignore duplicate events
      multi
    end
  end

  defp exists?(uuid) do
    Metrist.Agent.Projection.by_uuid(uuid)
    |> Metrist.Repo.exists?()
  end
end
