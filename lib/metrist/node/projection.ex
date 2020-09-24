defmodule Metrist.Node.Projection do
  @moduledoc """
  Read projection for nodes.
  """
  use Ecto.Schema
  import Ecto.Query

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "nodes" do
    field :account_uuid, :binary_id
    field :node_id, :string
  end

  def by_account_and_node_id(account_uuid, node_id) do
    from(n in __MODULE__,
      where: n.account_uuid == ^account_uuid
         and n.node_id == ^node_id)
  end

  def by_uuid(uuid) do
    from(n in __MODULE__,
      where: n.uuid == ^uuid)
  end
end
