defmodule Metrist.Repo.Migrations.Users do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :provider, :string
      add :provider_id, :string

      timestamps()
    end

    create unique_index(:users, [:provider, :provider_id])
  end
end
