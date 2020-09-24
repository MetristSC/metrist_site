defmodule Metrist.Node.Projector do
  use Commanded.Projections.Ecto,
    application: Metrist.App,
    repo: Metrist.Repo,
    name: "nodes_projector"

  alias Metrist.Node.Event
  require Logger

  project e = %Event.Created{}, fn multi ->
    if not exists?(e.uuid) do
      Logger.info("=== Making")
      Logger.info("??? #{inspect %Metrist.Node.Projection{}}")
      p = %Metrist.Node.Projection{uuid: e.uuid,
                                   account_uuid: e.account_uuid,
                                   node_id: e.node_id}
      Logger.info("<<< #{inspect p}")
      r = Ecto.Multi.insert(multi, :node, p)
      Logger.info(">>> #{inspect r}")
      r
    else
      # Ignore duplicate events
      multi
    end
  end

  defp exists?(uuid) do
    Metrist.Node.Projection.by_uuid(uuid)
    |> Metrist.Repo.exists?()
  end
end
