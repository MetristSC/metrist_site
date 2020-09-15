# This is an attempt to see how specific read projections
# work.
defmodule Metrist.Account.Projection.ByOwner do
  @moduledoc """
  Read projection to retrieve accounts for a certain
  owner.
  """
  use Ecto.Schema
  import Ecto.Query

  @primary_key {:owner_uuid, :binary_id, autogenerate: false}

  schema "accounts_by_owner" do
    field(:account_uuid, :binary_id)
  end

  def by_owner(owner_uuid) do
    from(a in __MODULE__,
      where: a.owner_uuid == ^owner_uuid,
      select: a.account_uuid)
  end
end
defmodule Metrist.Account.Projection.ByApiKey do
  @moduledoc """
  Read projection to retrieve account for a certain api key.
  """
  use Ecto.Schema
  import Ecto.Query

  @primary_key {:api_key, :binary_id, autogenerate: false}

  schema "accounts_by_api_key" do
    field :account_uuid, :binary_id
  end

  def by_api_key(api_key) do
    from(a in __MODULE__,
      where: a.api_key == ^api_key)
  end

  def api_keys(account_uuid) do
    from(a in __MODULE__,
      where: a.account_uuid == ^account_uuid,
      select: a.api_key)
  end
end
