defmodule Metrist.Agent.Projection do
  @moduledoc """
  Read projection for agents.
  """
  use Ecto.Schema
  import Ecto.Query

  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "agents" do
    field :account_uuid, :binary_id
    field :agent_id, :string
  end

  def by_account_and_agent_id(account_uuid, agent_id) do
    from(n in __MODULE__,
      where: n.account_uuid == ^account_uuid
         and n.agent_id == ^agent_id)
  end

  def by_account(account_uuid) do
    from(n in __MODULE__,
      where: n.account_uuid == ^account_uuid)
  end

  def by_uuid(uuid) do
    from(n in __MODULE__,
      where: n.uuid == ^uuid)
  end
end
