defmodule Metrist.Repo.Migrations.RenameNodeToAgent do
  use Ecto.Migration

  def change do
    rename table(:nodes), to: table(:agents)
    rename table(:agents), :node_id, to: :agent_id
  end
end
