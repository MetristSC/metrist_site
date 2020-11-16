defmodule Metrist.Agent.Projector do
  use Commanded.Projections.Ecto,
    application: Metrist.App,
    repo: Metrist.Repo,
    name: "agents_projector"

  alias Metrist.Agent.Event
  require Logger

  project e = %Event.Created{}, fn multi ->
    if not exists?(e.uuid) do
      p = %Metrist.Agent.Projection{uuid: e.uuid,
                                   account_uuid: e.account_uuid,
                                   agent_id: e.agent_id}
      r = Ecto.Multi.insert(multi, :agent, p)
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
