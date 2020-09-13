defmodule Metrist.Repo.Migrations.CreateAcccountsByOwner do
  use Ecto.Migration

  def change do
    create table(:accounts_by_owner, primary_key: false) do
      add :owner_uuid, :uuid, primary_key: true
      add :accounts, {:array, :string}
    end
  end
end
