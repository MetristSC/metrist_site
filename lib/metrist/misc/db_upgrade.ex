defmodule Metrist.Misc.DbUpgrade do
  @moduledoc """
  Database upgrade process for in production
  """

  # TODO error handling

  def run() do
    Application.ensure_loaded(:metrist)
    #ensure_repo_exists()
    ensure_eventstore_exists()
    #upgrade_repo()
    upgrade_eventstore()
  end

  defp ensure_repo_exists do
    IO.puts("=== Making sure that the database exists")
    IO.inspect Metrist.Repo.__adapter__.storage_up(Metrist.Repo.config)
  end

  defp ensure_eventstore_exists do
    IO.puts("=== Making sure that the event store exists")
    IO.inspect EventStore.Tasks.Create.exec(Metrist.EventStore.config(), [])
  end

  defp upgrade_repo do
    IO.puts("=== Migrating database")
    IO.inspect Ecto.Migrator.with_repo(Metrist.Repo, &Ecto.Migrator.run(&1, :up, all: true))
  end

  defp upgrade_eventstore do
    IO.puts("=== Initializing/upgrading event store")
    IO.inspect EventStore.Tasks.Init.exec(Metrist.EventStore, Metrist.EventStore.config(), [])
    IO.inspect EventStore.Tasks.Migrate.exec(Metrist.EventStore.config(), [])
  end
end
