defmodule Metrist.Repo.Migrations.CreateAccountsByApiKey do
  use Ecto.Migration

  def change do
    create table(:accounts_by_api_key, primary_key: false) do
      add :api_key, :uuid, primary_key: true
      add :account_uuid, :uuid
    end

    # We also want to lookup the api key for an account.
    create index(:accounts_by_api_key, [:account_uuid])
  end
end
