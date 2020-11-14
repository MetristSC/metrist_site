defmodule Metrist.Repo.Migrations.RenameNodeToAgent do
  use Ecto.Migration

  def change do
    rename table(:nodes), to: table(:agents)
  end
end
