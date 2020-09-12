defmodule MetristSite.Repo do
  use Ecto.Repo,
    otp_app: :metrist_site,
    adapter: Ecto.Adapters.Postgres
end
