defmodule Metrist.Account.Projection.ByOwner do
  @moduledoc """
  Read projection to retrieve accounts for a certain
  owner.
  """
  use Ecto.Schema
  import Ecto.Query

  @primary_key {:owner_uuid, :binary_id, autogenerate: false}

  schema "accounts_by_owner" do
    field(:accounts, {:array, :string})
  end

  def by_owner(owner_uuid) do
    from(a in __MODULE__,
      where: a.owner_uuid == ^owner_uuid)
  end
end
