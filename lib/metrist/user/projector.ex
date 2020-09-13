defmodule Metrist.User.Projector do
  use Commanded.Projections.Ecto,
    application: Metrist.App,
    repo: Metrist.Repo,
    name: "users_projector"

  alias Metrist.User.Event

  project e = %Event.Registered{}, fn multi ->
    # Ignore if we see this more than once.
    if not exists?(e.uuid) do
      Ecto.Multi.insert(multi, :user,
        %Metrist.User.Projection{uuid: e.uuid,
                                 provider: e.provider,
                                 provider_id: e.provider_id})
    else
        multi
    end
  end

  defp exists?(uuid) do
    Metrist.User.Projection.by_uuid(uuid)
    |> Metrist.Repo.exists?()
  end
end
