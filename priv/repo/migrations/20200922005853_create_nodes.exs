defmodule Metrist.Repo.Migrations.CreateNodes do
  use Ecto.Migration

  def change do
    create table(:nodes, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :account_uuid, :uuid
      add :node_id, :string
    end
    create index(:nodes, [:account_uuid, :node_id])
  end
end
