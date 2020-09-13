defmodule Metrist.Repo do
  use Ecto.Repo,
    otp_app: :metrist,
    adapter: Ecto.Adapters.Postgres
end
