defmodule MetristWeb.DashboardLive do
  use Phoenix.LiveView

  def render(assigns) do
    IO.puts("rendering with assigns: #{inspect assigns}")
    ~L"""
    Owner UUID: <%= @owner_uuid %>
    <br>
    Account UUID: <%= @account_uuid %>
    <br>
    API Key: <%= @api_key %>
    """
  end

  def mount(_params, session, socket) do
    pid = self()
    IO.puts("I am pid #{inspect pid}")
    if connected?(socket) do
      IO.puts("Starting poll")
      Task.async(fn -> poll_for_data(pid, session["current_user"]) end)
    else
      IO.puts("Hmm... socket not connected...")
      IO.puts("#{inspect socket}")
    end
    socket = socket
    |> assign(:owner_uuid, "Fetching...")
    |> assign(:account_uuid, "Fetching...")
    |> assign(:api_key, "Fetching...")
    {:ok, socket}
  end

  def handle_info({:owner_uuid, owner_uuid}, socket) do
    IO.puts("Retrieved owner uuid")
    {:noreply, assign(socket, :owner_uuid, owner_uuid)}
  end

  def handle_info({:account_uuid, account_uuid}, socket) do
    IO.puts("Retrieved account uuid")
    {:noreply, assign(socket, :account_uuid, account_uuid)}
  end

  def handle_info({:api_key, api_key}, socket) do
    IO.puts("Retrieved owner uuid")
    {:noreply, assign(socket, :api_key, api_key)}
  end

  def handle_info(msg, socket) do
    IO.puts("Hmm... #{inspect msg}")
    {:noreply, socket}
  end

  # Ok, not super clean, but I'm curious how far we can take
  # this and delays setting up a registry for a bit.
  # TODO cleanup
  defp poll_for_data(pid, user) do
    # Step one: owner uuid. We might be in a registration
    # so the uuid might not be there.
    owner_uuid = poll_for_owner_uuid(pid, user)
    # Same for account id and default api key
    account_uuid = poll_for_account_uuid(pid, owner_uuid)
    poll_for_api_key(pid, account_uuid)
    "Polling done. Plesae fix this hack"
  end

  defp poll_for_owner_uuid(pid, user) do
    result =
      Metrist.User.Projection.by_provider_and_id(
        to_string(user.provider),
        to_string(user.id))
      |> Metrist.Repo.one()
    if result == nil do
      Process.sleep(1_000)
      poll_for_owner_uuid(pid, user)
    else
      IO.puts("Got owner_uuid: #{inspect result}, telling #{inspect pid}")
      send(pid, {:owner_uuid, result})
      result
    end
  end
  defp poll_for_account_uuid(pid, owner_uuid) do
    result =
      Metrist.Account.Projection.ByOwner.by_owner(owner_uuid)
      |> Metrist.Repo.one()
    if result == nil do
      Process.sleep(1_000)
      poll_for_account_uuid(pid, owner_uuid)
    else
      IO.puts("Got account_uuid: #{inspect result}")
      send(pid, {:account_uuid, result})
      result
    end
  end
  defp poll_for_api_key(pid, account_uuid) do
    result =
      Metrist.Account.Projection.ByApiKey.api_keys(account_uuid)
      |> Metrist.Repo.one()
    if result == nil do
      Process.sleep(1_000)
      poll_for_api_key(pid, account_uuid)
    else
      IO.puts("Got api key: #{inspect result}")
      send(pid, {:api_key, result})
      result
    end
  end
end
