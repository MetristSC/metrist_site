defmodule Metrist.User.Projection do
  use Ecto.Schema
  import Ecto.Query

  @primary_key {:uuid, :binary_id, autogenerate: false}
  @timestamps_opts [type: :utc_datetime_usec]

  schema "users" do
    field(:provider, :string, unique: true)
    field(:provider_id, :string, unique: true)

    timestamps()
  end

  def by_provider_and_id(provider, id) do
    from(u in __MODULE__,
      where: u.provider == ^provider
      and u.provider_id == ^id)
  end

  def by_uuid(uuid) do
    from(u in __MODULE__, where: u.uuid == ^uuid)
  end
end
