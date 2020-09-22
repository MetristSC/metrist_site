defmodule Metrist.Account.Projector.ByOwner do
  use Commanded.Projections.Ecto,
    application: Metrist.App,
    repo: Metrist.Repo,
    name: "accounts_by_owner"

  alias Metrist.Account.Event
  alias Metrist.Account.Projection

  project e = %Event.Created{}, fn multi ->
    case Metrist.Repo.get(Projection.ByOwner, e.owner) do
      nil ->
        Ecto.Multi.insert(multi, :account,
          %Projection.ByOwner{owner_uuid: e.owner,
                              account_uuid: e.uuid})
      item ->
        Ecto.Multi.update(multi, :account, update_changeset(item, e))
    end
  end

  defp update_changeset(item, e) do
    Ecto.Changeset.change(item,
      account: e.uuid)
  end
end
defmodule Metrist.Account.Projector.ByApiKey do
  use Commanded.Projections.Ecto,
    application: Metrist.App,
    repo: Metrist.Repo,
    name: "accounts_by_api_key"

  alias Metrist.Account.Event
  alias Metrist.Account.Projection

  project e = %Event.Created{}, fn multi ->
    case Metrist.Repo.get(Projection.ByApiKey, e.api_key) do
      nil ->
        Ecto.Multi.insert(multi, :account,
          %Projection.ByApiKey{api_key: e.api_key,
                               account_uuid: e.uuid})
      item ->
        Ecto.Multi.update(multi, :account, update_changeset(item, e))
    end
  end

  defp update_changeset(item, e) do
    Ecto.Changeset.change(item,
      api_key: e.api_key)
  end
end
