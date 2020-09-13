defmodule Metrist.User.OAuthLogin do
  @doc """
  When we see an OAuth login, see whether the
  user exists. If not, register a user.
  """
  require Logger
  alias Metrist.User.Command

  def logged_in(auth) do
    id = to_string(auth.uid)
    provider = to_string(auth.provider)
    if not exists?(provider, id) do
      c = %Command.Register{
        uuid: Id.generate(),
        provider: provider,
        provider_id: id}
      Logger.info("User does not exist, dispatching registration command #{inspect c}")
      Metrist.App.dispatch(c)
    else
      Logger.info("User already in database")
    end
  end

  defp exists?(provider, id) do
    Metrist.User.Projection.by_provider_and_id(
      provider,
      id)
    |> Metrist.Repo.exists?()
  end
end
